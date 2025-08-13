#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include <QTcpSocket>
#include <QTimer>
class NetworkManager : public QObject {
	Q_OBJECT
		Q_PROPERTY(bool connected READ isConnected NOTIFY connectionChanged)
public:
	explicit NetworkManager(QObject* parent = nullptr);
	Q_INVOKABLE void connectToDevice(const QString& ip, quint16 port);
	Q_INVOKABLE void disconnectDevice();
	//Q_INVOKABLE void setFocalLength(float focalLength);
	//Q_INVOKABLE void upgradeFirmware(const char* filePath)
	bool isConnected() const;

	void handleReadyRead();

	void initSocket();
	
	void startReconnect();          // 启动重连定时器
	void stopReconnect();           // 停止重连定时器
signals:
	void connectionChanged(bool connected);
	void errorOccurred(const QString& error);
	void dataReceived(const QByteArray& data);
	void socketReady();
public slots:
	void onSendData(const QByteArray& data);

	void attemptReconnect();         // 定时器触发，尝试重连
private slots:
	void onConnected();
	void onDisconnected();
	void onError(QAbstractSocket::SocketError error);
	
private:
	QTcpSocket* m_socket;
	bool m_connected;
	QTimer* m_reconnectTimer = nullptr;
	QString m_ip;
	int m_port;
};

#endif
