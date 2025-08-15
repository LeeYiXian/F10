#include "NetworkManager.h"
#include <QThread>
#include <QDateTime>
NetworkManager::NetworkManager(QObject* parent)
	: QObject(parent), m_socket(nullptr), m_connected(false)
{
	QThread* netThread = new QThread(this);

	connect(netThread, &QThread::finished, this, &QObject::deleteLater);

	this->moveToThread(netThread);

	// ���߳��������ڸ��߳��д��� socket
	connect(netThread, &QThread::started, this, &NetworkManager::initSocket, Qt::QueuedConnection);

	netThread->start();
}

void NetworkManager::initSocket()
{
	m_reconnectTimer = new QTimer();
	connect(m_reconnectTimer, &QTimer::timeout, this, &NetworkManager::attemptReconnect);
	m_reconnectTimer->setInterval(2000); // ÿ2�볢��һ��

	m_timeoutTimer = new QTimer();
	connect(m_timeoutTimer, &QTimer::timeout, this, &NetworkManager::onSendTimeout);
	m_timeoutTimer->setInterval(2000); // 10�볬ʱ

	m_socket = new QTcpSocket(this);

	connect(m_socket, &QTcpSocket::connected, this, &NetworkManager::onConnected);
	connect(m_socket, &QTcpSocket::disconnected, this, &NetworkManager::onDisconnected);
	connect(m_socket, &QTcpSocket::errorOccurred, this, &NetworkManager::onError);
	connect(m_socket, &QTcpSocket::readyRead, this, &NetworkManager::handleReadyRead);

	emit socketReady(); // ֪ͨ�ⲿ socket ������
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
	
	// �յ����ݺ󣬰Ѷ���ͷ�Ƴ�
	if (m_waitingResponse && !m_sendQueue.isEmpty()) {
		m_timeoutTimer->stop();
		emit dataReceived(data, m_sendQueue.dequeue());
		m_waitingResponse = false;
		// ���������Ϣ������������һ��
		if (!m_sendQueue.isEmpty()) {
			sendNextInQueue();
		}
	}
}

void NetworkManager::onSendData(const QByteArray& data)
{
	// �Ȱ����ݼ������
	m_sendQueue.enqueue(data);

	// �����ǰû�еȴ���Ӧ���ͷ��Ͷ���ͷ
	if (!m_waitingResponse) {
		sendNextInQueue();
	}
}

void NetworkManager::sendNextInQueue()
{
	if (m_sendQueue.isEmpty() || !m_connected || !m_socket) return;

	QByteArray data = m_sendQueue.head(); // �鿴����ͷ
	m_waitingResponse = true;

	qDebug() << "Send Data (" << data.size() << "bytes):" << data.toHex(' ').toUpper();

	m_socket->write(data);
	m_socket->flush();

	m_timeoutTimer->start(); // ÿ����Ϣ������ʱ
}

void NetworkManager::onSendTimeout()
{
	if (!m_waitingResponse) return; // �Ѿ��յ���Ӧ������
	qWarning() << "Timeout waiting for device response; drop head and continue.";

	if (!m_sendQueue.isEmpty())
		m_sendQueue.dequeue();      // ��������δ�ص���Ϣ

	m_waitingResponse = false;
	if (!m_sendQueue.isEmpty())
		sendNextInQueue();          // ������һ�����������忨��
}