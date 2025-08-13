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

	m_reconnectTimer = new QTimer(this);
	connect(m_reconnectTimer, &QTimer::timeout, this, &NetworkManager::attemptReconnect);
	m_reconnectTimer->setInterval(2000); // 每2秒尝试一次
	m_reconnectTimer->setSingleShot(false);
}

void NetworkManager::initSocket()
{
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
}

void NetworkManager::onError(QAbstractSocket::SocketError error) {
	m_connected = false;
	emit errorOccurred(m_socket->errorString());
	emit connectionChanged(false);
}

void NetworkManager::handleReadyRead()
{
	QByteArray data = m_socket->readAll();
	emit dataReceived(data);
}

void NetworkManager::onSendData(const QByteArray& data)
{
	if (!m_connected || !m_socket) {
		emit errorOccurred(tr("Not connected to device"));
		return;
	}

	// 打印发送的数据（十六进制，空格分隔）
	qDebug() << "Send Data (" << data.size() << "bytes):" << data.toHex(' ').toUpper();

	m_socket->write(data);
	QThread::msleep(100); // 延时100毫秒，等待数据发送完毕
}