#pragma once
#include <QObject>
#include <QVariant>
#include <NetworkManager.h>
#include <SerialPort.h>
#include <QTimer>
#include "linearguiderailimpl.h"
#include "filterWheelImpl.h"
#include "stm2038bimpl.h"
#include "axisclass.h"
#include "Loggers.h"
#include <atomic>
#include "ServoUdp.h"
#include "ProcessLauncher.h"
#include "ConfigManager.h"
#define AXISNUM 4
class QmlCppBridge : public QObject {
    Q_OBJECT
public:
    explicit QmlCppBridge(QObject* parent = nullptr);

	template <typename T>
	QByteArray serializeMessage(const T& requestMsg);
signals:
    //zmq收到的数据传给qml展示
    void sendtoQml(const QVariant& data);

	void sendtoSwitchMechanism(const QByteArray& data);
	void sendtoFilterWheel(const QByteArray& data);
	void sendtoWavePlate(const QByteArray& data);

	void sendSerialData(const QByteArray& data);

	void sgnDmcInit();
public slots:
	void sendtoCpp(const QVariant& data);

    void handleReceivedSerialData(const QByteArray& data);

    void handleReceivedNetworkData(const QByteArray& data, const QByteArray& cmd);

	void handleReceivedServoData(const QByteArray& data);

	void onConnectStatus(bool status);
public slots:
	void onReceivedMsg(const QVariant& params);

	void sendHeartbeat();

	void onDmcInit();

	void onScreenShot();
public://支撑平台相关接口
	void DmcInit();
	void ConfigAxis(int i, AxisClass* pAxis);
	void DmcDistory();
	void QureyAxisStatus();
	AxisClass* getAxisByTarget(AxisTarget target, const QString& targetStr);

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

	/*************************升降台 起*********************************/
	DWORD    m_ConnectNum;//连接编号
	DWORD    m_wCard;//卡号
	QString  m_strIPAdress;//IP地址
	std::vector<AxisClass> axisClasses;
	bool    m_MCConnecState;//0 离线 1在线
	bool    m_MCEnableState;//0 使能开 1使能关
	AxisClass* pAxis[AXISNUM];
	/*************************升降台 终*********************************/

	

	/*离线检测计数器*/
	std::atomic<int> m_switchMissCount{ 0 };
	std::atomic<int> m_filterMissCount{ 0 };
	std::atomic<int> m_waveMissCount{ 0 };

	std::atomic<bool> m_switchOnline{ false };
	std::atomic<bool> m_filterOnline{ false };
	std::atomic<bool> m_waveOnline{ false };
	/*离线检测计数器*/

	/*伺服通信*/
	ServoUdp* m_servoUdp;
	
	QTimer m_heartbeatTimer;
	QTimer m_receiveTimer;
	int m_hbCount = 0;

	/*伺服通信*/
	ProcessLauncher m_processLauncher;
	//快反镜FastMirrorController、光束质量分析仪BeamQualityAnalyzer、光偏振检测仪PolarizationAnalyzer
	ConfigManager m_configManager;
};
