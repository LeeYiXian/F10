#include "QmlCppBridge.h"
#include <QDebug>
#include <QCryptographicHash>
#include <QDateTime>
#include <QThread>

#define MAX_SEND_BUFFER_SIZE 256

QmlCppBridge::QmlCppBridge(QObject * parent)
    : QObject(parent) 
{
	m_switchMechanismNetMgr = new NetworkManager();
	m_filterWheelNetMgr = new NetworkManager();
	m_wavePlateNetMgr = new NetworkManager();

	m_linearGuiderailImpl = new LinearGuideRailImpl();
	m_filterWheelImpl = new FilterWheelImpl();
	m_stm2038BImpl = new Stm2038bImpl();

	//根据地址修改
	m_switchMechanismNetMgr->connectToDevice("127.0.0.1", 1234);
	m_filterWheelNetMgr->connectToDevice("127.0.0.1", 1235);
	m_wavePlateNetMgr->connectToDevice("127.0.0.1", 1236);

	connect(m_switchMechanismNetMgr, &NetworkManager::dataReceived, this, &QmlCppBridge::handlReceivedNetworkData);
	connect(m_filterWheelNetMgr, &NetworkManager::dataReceived, this, &QmlCppBridge::handlReceivedNetworkData);
	connect(m_wavePlateNetMgr, &NetworkManager::dataReceived, this, &QmlCppBridge::handlReceivedNetworkData);


    m_serialPort = new SerialPort();
	connect(m_serialPort, &SerialPort::dataReceived, this, &QmlCppBridge::handleReceivedSerialData);

	QThread* thread = new QThread();
	auto worker = [=]() {
		while (true)
		{
			//切换机构状态查询

			//滤光轮状态查询

			//波片状态查询

			QThread::msleep(200);
		}
	};
	QObject::connect(thread, &QThread::started, worker);
	QObject::connect(thread, &QThread::finished, thread, &QThread::deleteLater);
	thread->start();
}

void QmlCppBridge::sendtoCpp(const QVariant& data)
{
	if (!data.canConvert<QVariantMap>()) {
		qDebug() << "Invalid data type";
		return;
	}

	QVariantMap map = data.toMap();
	QString method = map["method"].toString();
	method.remove(QChar(0x200C));  // 显式移除零宽非连接符

	char outBuffer[MAX_SEND_BUFFER_SIZE] = { 0 };
	int sendLen = 0;

	auto sendToDevice = [&](auto netMgr, auto action) {
		memset(outBuffer, 0, sizeof(outBuffer));
		sendLen = action();
		netMgr->sendData(QByteArray(outBuffer, sendLen));
		};

	if (method == "switchmechanism.open") {
		sendToDevice(m_switchMechanismNetMgr, [&] {
			return m_linearGuiderailImpl->moveByStep(1, 90000, outBuffer);
			});
	}
	else if (method == "switchmechanism.close") {
		sendToDevice(m_switchMechanismNetMgr, [&] {
			return m_linearGuiderailImpl->moveByStep(1, -90000, outBuffer);
			});
	}
	else if (method == "switchmechanism.findzero") {
		sendToDevice(m_switchMechanismNetMgr, [&] {
			return m_linearGuiderailImpl->motorZeroing(1, outBuffer);
			});
	}
	else if (method == "filterwheel.setgear") {
		int index = map["value"].toInt();
		static const QMap<int, int> gearMap = {
			{0, 1600}, {1, 3200}, {2, 4800}, {3, 6400}
		};
		if (!gearMap.contains(index)) {
			qDebug() << "Invalid filter wheel index";
			return;
		}
		sendToDevice(m_filterWheelNetMgr, [&] {
			return m_filterWheelImpl->moveToSetPosition(index, gearMap[index], outBuffer);
			});
	}
	else if (method == "waveplate.open") {
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->setContorMode(1, outBuffer); });
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->setWorkMode(1, m_stm2038BImpl->workModes::POSITION_CONTROL, outBuffer); });
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->setTargetPosition(1, 1600, outBuffer); });
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->motorEnablement(1, outBuffer); });
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->moveToSetPosition(1, 1600, outBuffer); });
	}
	else if (method == "waveplate.close") {
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->setContorMode(1, outBuffer); });
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->setWorkMode(1, m_stm2038BImpl->workModes::POSITION_CONTROL, outBuffer); });
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->setTargetPosition(1, 1600, outBuffer); });
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->motorEnablement(1, outBuffer); });
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->moveToSetPosition(1, 1600, outBuffer); });
	}
	else if (method == "waveplate.findzero") {
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->setContorMode(1, outBuffer); });
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->setWorkMode(1, m_stm2038BImpl->workModes::ZEROPOINT_MODEING, outBuffer); });
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->motorEnablement(1, outBuffer); });
	}

    else if (method == "supportplatform.enable")
    {
        QString target  = map["target"].toString();
        qDebug()<<"target:"<<target;
        if (target == "platform.x")
        {
            //发给支撑平台方位
            
        }
        else if (target == "platform.y")
        {
            //发给支撑平台俯仰
        }
        else if (target == "platform.z")
        {
            //发给支撑平台高低
        }
        else if (target == "platform.height")
        {
            //发给大升降台
        }
        
    }
    else if (method == "supportplatform.stop")
    {
		QString target = map["target"].toString();
		qDebug() << "target:" << target;
		if (target == "platform.x")
		{
			//发给支撑平台方位

		}
		else if (target == "platform.y")
		{
			//发给支撑平台俯仰
		}
		else if (target == "platform.z")
		{
			//发给支撑平台高低
		}
		else if (target == "platform.height")
		{
			//发给大升降台
		}
    }
    else if (method == "supportplatform.forward")
    {
		QString target = map["target"].toString();
		qDebug() << "target:" << target;
		if (target == "platform.x")
		{
			//发给支撑平台方位

		}
		else if (target == "platform.y")
		{
			//发给支撑平台俯仰
		}
		else if (target == "platform.z")
		{
			//发给支撑平台高低
		}
		else if (target == "platform.height")
		{
			//发给大升降台
		}
    }
    else if (method == "supportplatform.backward")
    {
		QString target = map["target"].toString();
		qDebug() << "target:" << target;
		if (target == "platform.x")
		{
			//发给支撑平台方位

		}
		else if (target == "platform.y")
		{
			//发给支撑平台俯仰
		}
		else if (target == "platform.z")
		{
			//发给支撑平台高低
		}
		else if (target == "platform.height")
		{
			//发给大升降台
		}
    }
    else if (method == "supportplatform.position")
    {

		QString target = map["target"].toString();
		qDebug() << "target:" << target;
		if (target == "platform.x")
		{
			//发给支撑平台方位

		}
		else if (target == "platform.y")
		{
			//发给支撑平台俯仰
		}
		else if (target == "platform.z")
		{
			//发给支撑平台高低
		}
		else if (target == "platform.height")
		{
			//发给大升降台
		}
    }
	//微震动台x轴
	else if (method == "shakingtable.open")
	{
		if (map["chl"].toString() == "x")//微震动台x轴
		{

		}
		else if (map["chl"].toString() == "y")//微震动台y轴
		{

		}
	}
	else if (method == "shakingtable.close")
	{
		if (map["chl"].toString() == "x")//微震动台x轴
		{

		}
		else if (map["chl"].toString() == "y")//微震动台y轴
		{

		}
	}


}

void QmlCppBridge::handleReceivedSerialData(const QByteArray& data)
{

}

void QmlCppBridge::handlReceivedNetworkData(const QByteArray& data)
{
	//判断信号来自哪个sender
	QObject* sender = QObject::sender();

	if (sender == m_switchMechanismNetMgr)
	{
		//todo:处理接收到的切换机构数据
	}
	else if (sender == m_filterWheelNetMgr)
	{
		//todo:处理接收到的滤光轮数据
	}
	else if (sender == m_wavePlateNetMgr)
	{
		//todo:处理接收到的波片数据
	}

}

void QmlCppBridge::onReceivedMsg(const QVariant& params)
{
    // 仅做基础类型检查后直接转发
    if (params.canConvert<QVariantMap>()) {
        emit sendtoQml(params); // 直接传递原始 QVariant
    }
}
