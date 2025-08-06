#pragma once
#include <QObject>
#include <QVariant>
#include <NetworkManager.h>
#include <SerialPort.h>
class QmlCppBridge : public QObject {
    Q_OBJECT
public:
    explicit QmlCppBridge(QObject* parent = nullptr);

signals:
    //zmq收到的数据传给qml展示
    void sendtoQml(const QVariant& data);

public slots:
	void sendtoCpp(const QVariant& data);

public slots:
    void onReceivedMsg(const QVariant& params);
private:
    NetworkManager* m_networkManager;
    SerialPort* m_serialPort;
};
