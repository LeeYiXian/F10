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
    
	/*************************微振动台*********************************/
	// 状态变量
	QString xGearStatus;       // x轴当前档位
	QString xRunStatus;        // x轴运行状态
	QString yGearStatus;       // y轴当前档位
	QString yRunStatus;        // y轴运行状态
	QString dualAxisRunStatus; // 双轴转台运行状态
	//地址变量
	int m_addr;
	//更新状态的方法
	void updateXStatus(const QString& gear, const QString& run);
	void updateYStatus(const QString& gear, const QString& run);
	void updateDualAxisStatus(const QString& status);
	//辅助计算的函数
	unsigned char calcBit(const unsigned char* buffers, int len);
	unsigned char* doubleToChar(double fValue, unsigned char* kk);
	double charToDouble(char* kk);
	/*************************微振动台*********************************/
};
