#include "NetworkManager.h"
#include <QThread>
NetworkManager::NetworkManager(QObject * parent)
	: QObject(parent), m_socket(new QTcpSocket(this)), m_connected(false) {

	// 创建网络线程
	QThread* netThread = new QThread(this);
	this->moveToThread(netThread);
	m_socket->moveToThread(netThread);

	connect(netThread, &QThread::finished, m_socket, &QObject::deleteLater);

	connect(m_socket, &QTcpSocket::connected, this, &NetworkManager::onConnected);
	connect(m_socket, &QTcpSocket::disconnected, this, &NetworkManager::onDisconnected);
	connect(m_socket, &QTcpSocket::errorOccurred,this, &NetworkManager::onError);
	connect(m_socket, &QTcpSocket::readyRead, this, &NetworkManager::handleReadyRead);

	// 启动线程
	netThread->start();
}

void NetworkManager::connectToDevice(const QString& ip, quint16 port) {
	if (m_connected) return;
	m_socket->connectToHost(ip, port);
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

qint64 NetworkManager::onSendData(const QByteArray& data)
{
	if (!m_connected || !m_socket) {
		emit errorOccurred(tr("Not connected to device"));
		return -1;
	}
	return m_socket->write(data);
}