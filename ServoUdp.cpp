#include "ServoUdp.h"
#include <QUdpSocket>
#include <QDateTime>
#include <QPointer>
#include <QMetaObject>
#include <QDebug>
#include <QMetaType>
#include <QTimer>
#include "Utils.h"
Q_DECLARE_METATYPE(QHostAddress)
// ========== 工作对象，真正跑在子线程 ==========
class ServoUdpWorker : public QObject
{
	Q_OBJECT
public:
	explicit ServoUdpWorker(QObject* parent = nullptr)
		: QObject(parent)
	{

	}

public slots:
	void init(quint16 localPort, QHostAddress remoteAddr, quint16 remotePort)
	{
		if (m_socket) {
			return;
		}

		m_socket = new QUdpSocket(this);

		// 尝试绑定（可按需改成 ShareAddress/ReuseAddressHint）
		if (!m_socket->bind(QHostAddress::AnyIPv4, localPort)) {
			emit errorOccurred(QStringLiteral("Bind failed on port %1: %2")
				.arg(localPort)
				.arg(m_socket->errorString()));
			m_socket->deleteLater();
			m_socket = nullptr;
			return;
		}

		connect(m_socket, &QUdpSocket::readyRead,
			this, &ServoUdpWorker::onReadyRead, Qt::DirectConnection);
#if QT_VERSION >= QT_VERSION_CHECK(5, 15, 0)
		connect(m_socket, &QUdpSocket::errorOccurred,
			this, [this](QUdpSocket::SocketError) {
				emit errorOccurred(m_socket->errorString());
			}, Qt::DirectConnection);
#endif
		m_remoteAddr = remoteAddr;
		m_remotePort = remotePort;

		emit bound(localPort);
	}

	void shutdown()
	{
		if (m_socket) {
			m_socket->close();
			m_socket->deleteLater();
			m_socket = nullptr;
		}
	}

	void setRemote(QHostAddress addr, quint16 port)
	{
		m_remoteAddr = std::move(addr);
		m_remotePort = port;
	}

	void rebind(quint16 localPort)
	{
		if (!m_socket) {
			emit errorOccurred(QStringLiteral("Socket not initialized"));
			return;
		}
		m_socket->close();
		if (!m_socket->bind(QHostAddress::AnyIPv4, localPort)) {
			emit errorOccurred(QStringLiteral("Rebind failed on port %1: %2")
				.arg(localPort)
				.arg(m_socket->errorString()));
			return;
		}
		emit bound(localPort);
	}

	void send(const QByteArray& data)
	{
		if (!m_socket) {
			emit errorOccurred(QStringLiteral("Socket not initialized"));
			return;
		}
		if (m_remoteAddr.isNull() || m_remotePort == 0) {
			emit errorOccurred(QStringLiteral("Remote address/port not set"));
			return;
		}
		const qint64 written = m_socket->writeDatagram(data, m_remoteAddr, m_remotePort);
		if (written < 0) {
			emit errorOccurred(QStringLiteral("Send failed: %1").arg(m_socket->errorString()));
			return;
		}
		emit sent(written);
	}

private slots:
	void onReadyRead()
	{
		if (!m_socket) return;

		while (m_socket->hasPendingDatagrams()) {
			QHostAddress from;
			quint16 port = 0;
			QByteArray buf;
			buf.resize(int(m_socket->pendingDatagramSize()));
			const qint64 n = m_socket->readDatagram(buf.data(), buf.size(), &from, &port);
			if (n >= 0) {
				buf.resize(int(n));
				emit received(buf, from, port);
			}
			else {
				emit errorOccurred(QStringLiteral("Read failed: %1").arg(m_socket->errorString()));
				break;
			}
		}
	}


signals:
	void received(const QByteArray& data, const QHostAddress& from, quint16 port);
	void sent(qint64 bytes);
	void bound(quint16 localPort);
	void errorOccurred(const QString& message);

private:
	QUdpSocket* m_socket = nullptr;
	QHostAddress m_remoteAddr;
	quint16 m_remotePort = 0;

};

// ========== 对外门面类，负责线程管理 ==========
ServoUdp::ServoUdp(quint16 localPort,
	const QHostAddress& remoteAddr,
	quint16 remotePort,
	QObject* parent)
	: QObject(parent)
{
	qRegisterMetaType<QHostAddress>("QHostAddress");
	m_worker = new ServoUdpWorker();

	// 跨线程信号桥接到外部
	connect(m_worker, &ServoUdpWorker::received, this, &ServoUdp::received, Qt::QueuedConnection);
	connect(m_worker, &ServoUdpWorker::sent, this, &ServoUdp::sent, Qt::QueuedConnection);
	connect(m_worker, &ServoUdpWorker::bound, this, &ServoUdp::bound, Qt::QueuedConnection);
	connect(m_worker, &ServoUdpWorker::errorOccurred, this, &ServoUdp::errorOccurred, Qt::QueuedConnection);

	// 把 worker 移入线程并启动
	m_worker->moveToThread(&m_thread);
	connect(&m_thread, &QThread::finished, m_worker, &QObject::deleteLater);
	connect(&m_thread, &QThread::started, [=] {
		QMetaObject::invokeMethod(
			m_worker, "init",
			Qt::QueuedConnection,
			Q_ARG(quint16, localPort),
			Q_ARG(QHostAddress, remoteAddr),
			Q_ARG(quint16, remotePort));
		});

	m_thread.start();
}

ServoUdp::~ServoUdp()
{
	if (m_worker) {
		QMetaObject::invokeMethod(m_worker, "shutdown", Qt::BlockingQueuedConnection);
	}
	m_thread.quit();
	m_thread.wait();
}

void ServoUdp::send(const QByteArray& data)
{
	if (!m_worker) return;
	QMetaObject::invokeMethod(m_worker, "send", Qt::QueuedConnection,
		Q_ARG(QByteArray, data));
}

void ServoUdp::rebind(quint16 localPort)
{
	if (!m_worker) return;
	QMetaObject::invokeMethod(m_worker, "rebind", Qt::QueuedConnection,
		Q_ARG(quint16, localPort));
}

void ServoUdp::setRemote(const QHostAddress& addr, quint16 port)
{
	if (!m_worker) return;
	QMetaObject::invokeMethod(m_worker, "setRemote", Qt::QueuedConnection,
		Q_ARG(QHostAddress, addr),
		Q_ARG(quint16, port));
}

#include "ServoUdp.moc"
