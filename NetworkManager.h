#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include <QTcpSocket>

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
	qint64 sendData(const QByteArray& data);
signals:
	void connectionChanged(bool connected);
	void errorOccurred(const QString& error);
	void dataReceived(const QByteArray& data);
private slots:
	void onConnected();
	void onDisconnected();
	void onError(QAbstractSocket::SocketError error);

private:
	QTcpSocket* m_socket;
	bool m_connected;
};

#endif
