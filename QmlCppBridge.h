#pragma once
#include <QObject>
#include <QVariant>
#include <NetworkManager.h>
#include <SerialPort.h>
#include <QTimer>
#include "linearguiderailimpl.h"
#include "filterWheelImpl.h"
#include "stm2038bimpl.h"
class QmlCppBridge : public QObject {
    Q_OBJECT
public:
    explicit QmlCppBridge(QObject* parent = nullptr);
signals:
    //zmq收到的数据传给qml展示
    void sendtoQml(const QVariant& data);

public slots:
	void sendtoCpp(const QVariant& data);

    void handleReceivedSerialData(const QByteArray& data);

    void handlReceivedNetworkData(const QByteArray& data);

public slots:
    void onReceivedMsg(const QVariant& params);
private:
    SerialPort* m_serialPort;
	FilterWheelImpl* m_filterWheelImpl;
	LinearGuideRailImpl* m_linearGuiderailImpl;
	Stm2038bImpl* m_stm2038BImpl;

	NetworkManager* m_switchMechanismNetMgr;  // 切换机构
	NetworkManager* m_filterWheelNetMgr;  // 滤光轮
    NetworkManager* m_wavePlateNetMgr;    // 波片
    
};
