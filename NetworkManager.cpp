#include "NetworkManager.h"
#include <QThread>
#include <QDateTime>
NetworkManager::NetworkManager(QObject* parent)
	: QObject(parent), m_socket(nullptr), m_connected(false)
{
	QThread* netThread = new QThread(this);

	connect(netThread, &QThread::finished, this, &QObject::deleteLater);

	this->moveToThread(netThread);

	// 在线程启动后，在该线程中创建 socket
	connect(netThread, &QThread::started, this, &NetworkManager::initSocket, Qt::QueuedConnection);

	netThread->start();
}

void NetworkManager::initSocket()
{
	m_reconnectTimer = new QTimer();
	connect(m_reconnectTimer, &QTimer::timeout, this, &NetworkManager::attemptReconnect);
	m_reconnectTimer->setInterval(2000); // 每2秒尝试一次

	m_timeoutTimer = new QTimer();
	connect(m_timeoutTimer, &QTimer::timeout, this, &NetworkManager::onSendTimeout);
	m_timeoutTimer->setInterval(2000); // 10秒超时

	m_socket = new QTcpSocket(this);

	connect(m_socket, &QTcpSocket::connected, this, &NetworkManager::onConnected);
	connect(m_socket, &QTcpSocket::disconnected, this, &NetworkManager::onDisconnected);
	connect(m_socket, &QTcpSocket::errorOccurred, this, &NetworkManager::onError);
	connect(m_socket, &QTcpSocket::readyRead, this, &NetworkManager::handleReadyRead);

	emit socketReady(); // 通知外部 socket 可用了
}

void NetworkManager::connectToDevice(const QString& ip, quint16 port) {
	if (m_connected) return;
	m_ip = ip;
	m_port = port;
	m_socket->connectToHost(m_ip, m_port);
	if (!m_socket->waitForConnected(3000)) {
		qDebug() << "Connection failed:" << m_socket->errorString();
		startReconnect();
		return;
	}
	stopReconnect();
}

void NetworkManager::startReconnect()
{
	if (!m_reconnectTimer->isActive()) {
		qDebug() << "Starting reconnect attempts...";
		m_reconnectTimer->start();
	}
}

void NetworkManager::stopReconnect()
{
	if (m_reconnectTimer->isActive()) {
		qDebug() << "Connected. Stopping reconnect attempts.";
		m_reconnectTimer->stop();
	}
}

void NetworkManager::attemptReconnect()
{
	qDebug() << "Attempting to reconnect to laser device...";

	connectToDevice(m_ip, m_port);
}

void NetworkManager::disconnectDevice() {
	if (m_connected) {
		m_socket->disconnectFromHost();
	}
}

bool NetworkManager::isConnected() const {
	return m_connected;
}

void NetworkManager::onConnected() {
	m_connected = true;
	emit connectionChanged(true);
}

void NetworkManager::onDisconnected() {
	m_connected = false;
	emit connectionChanged(false);
	startReconnect();
}

void NetworkManager::onError(QAbstractSocket::SocketError error) {
	m_connected = false;
	emit errorOccurred(m_socket->errorString());
	emit connectionChanged(false);
}

void NetworkManager::handleReadyRead()
{
	QByteArray data = m_socket->readAll();
	
	// 收到数据后，把队列头移除
	if (m_waitingResponse && !m_sendQueue.isEmpty()) {
		m_timeoutTimer->stop();
		emit dataReceived(data, m_sendQueue.dequeue());
		m_waitingResponse = false;
		// 如果还有消息，继续发送下一条
		if (!m_sendQueue.isEmpty()) {
			sendNextInQueue();
		}
	}
}

void NetworkManager::onSendData(const QByteArray& data)
{
	// 先把数据加入队列
	m_sendQueue.enqueue(data);

	// 如果当前没有等待响应，就发送队列头
	if (!m_waitingResponse) {
		sendNextInQueue();
	}
}

void NetworkManager::sendNextInQueue()
{
	if (m_sendQueue.isEmpty() || !m_connected || !m_socket) return;

	QByteArray data = m_sendQueue.head(); // 查看队列头
	m_waitingResponse = true;

	qDebug() << "Send Data (" << data.size() << "bytes):" << data.toHex(' ').toUpper();

	m_socket->write(data);
	m_socket->flush();

	m_timeoutTimer->start(); // 每条消息独立超时
}

void NetworkManager::onSendTimeout()
{
	if (!m_waitingResponse) return; // 已经收到响应，忽略
	qWarning() << "Timeout waiting for device response; drop head and continue.";

	if (!m_sendQueue.isEmpty())
		m_sendQueue.dequeue();      // 丢弃这条未回的消息

	m_waitingResponse = false;
	if (!m_sendQueue.isEmpty())
		sendNextInQueue();          // 继续下一条，避免总体卡死
}