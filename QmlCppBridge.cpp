#include "QmlCppBridge.h"
#include <QDebug>
#include <QCryptographicHash>
#include <QDateTime>
#include <QThread>

#define MAX_SEND_BUFFER_SIZE 256

QmlCppBridge::QmlCppBridge(QObject * parent)
    : QObject(parent) 
{
    m_networkManager = new NetworkManager();
    m_serialPort = new SerialPort();

	connect(m_networkManager, &NetworkManager::dataReceived, this, &QmlCppBridge::handlReceivedNetworkData);
	connect(m_serialPort, &SerialPort::dataReceived, this, &QmlCppBridge::handleReceivedSerialData);

	m_timer = new QTimer(this);
	connect(m_timer, &QTimer::timeout, [this]() {
		//组装查询

	});
	m_timer->start(200);
}



void QmlCppBridge::sendtoCpp(const QVariant& data)
{
    if (!data.canConvert<QVariantMap>())
    {
        qDebug() << "Invalid data type";
        return;
    }

	QVariantMap map = data.toMap();
	QString method = map["method"].toString();

	method.remove(QChar(0x200C));  // 显式移除零宽非连接符
	//发送的数据和长度
	char outBuffer[MAX_SEND_BUFFER_SIZE] = { 0 };
	int sendLen = 0;

	if (method == "switchmechanism.open")
	{
		sendLen = m_linearGuiderailImpl->moveByStep(1, 90000, outBuffer);

		//todo:发送给设备
	}
	else if (method == "switchmechanism.close")
	{
		sendLen = m_linearGuiderailImpl->moveByStep(1, -90000, outBuffer);

		//todo:发送给设备
	}
	else if (method == "switchmechanism.findzero")
	{
		sendLen = m_linearGuiderailImpl->motorZeroing(1, outBuffer);

		//todo:发送给设备
	}
	else if (method == "filterwheel.setgear‌")
	{
		//取出挡位值
		int index = map["value"].toInt();
		if (1 == index)
		{
			sendLen = m_filterWheelImpl->moveToSetPosition(index, 1600, outBuffer);

			//todo:发送给设备
		}
		else if (2 == index)
		{
			sendLen = m_filterWheelImpl->moveToSetPosition(index, 3200, outBuffer);
			//todo:发送给设备
		}
		else if (3 == index)
		{
			sendLen = m_filterWheelImpl->moveToSetPosition(index, 4800, outBuffer);

			//todo:发送给设备
		}
		else if (4 == index)
		{
			sendLen = m_filterWheelImpl->moveToSetPosition(index, 6400, outBuffer);

			//todo:发送给设备
		}
		else
		{
			qDebug() << "Invalid filter wheel index";
			return;
		}

	}
	else if (method == "waveplate.open")
	{
		//设置控制模式
		sendLen = m_stm2038BImpl->setContorMode(1, outBuffer);

		//todo:发送给设备 

		//设置工作模式
		memset(outBuffer, 0, sizeof(outBuffer));
		sendLen = m_stm2038BImpl->setWorkMode(1, m_stm2038BImpl->workModes::POSITION_CONTROL, outBuffer);

		//todo:发送给设备

		//设置目标位置
		memset(outBuffer, 0, sizeof(outBuffer));
		sendLen = m_stm2038BImpl->setTargetPosition(1, 1600, outBuffer);

		//todo:发送给设备

		//电机使能
		memset(outBuffer, 0, sizeof(outBuffer));
		sendLen = m_stm2038BImpl->motorEnablement(1, outBuffer);

		//todo:发送给设备

		//运动到指定位置
		memset(outBuffer, 0, sizeof(outBuffer));
		sendLen = m_stm2038BImpl->moveToSetPosition(1, 1600, outBuffer);

		//todo:发送给设备

	}
	else if (method == "waveplate.close")
	{
		//设置控制模式
		sendLen = m_stm2038BImpl->setContorMode(1, outBuffer);

		//todo:发送给设备 

		//设置工作模式
		memset(outBuffer, 0, sizeof(outBuffer));
		sendLen = m_stm2038BImpl->setWorkMode(1, m_stm2038BImpl->workModes::POSITION_CONTROL, outBuffer);

		//todo:发送给设备

		//设置目标位置
		memset(outBuffer, 0, sizeof(outBuffer));
		sendLen = m_stm2038BImpl->setTargetPosition(1, 1600, outBuffer);

		//todo:发送给设备

		//电机使能
		memset(outBuffer, 0, sizeof(outBuffer));
		sendLen = m_stm2038BImpl->motorEnablement(1, outBuffer);

		//todo:发送给设备

		//运动到指定位置
		memset(outBuffer, 0, sizeof(outBuffer));
		sendLen = m_stm2038BImpl->moveToSetPosition(1, 1600, outBuffer);

		//todo:发送给设备

	}
	else if (method == "waveplate.findzero")
	{
		//设置控制模式
		sendLen = m_stm2038BImpl->setContorMode(1, outBuffer);

		//todo:发送给设备 

		//设置工作模式
		memset(outBuffer, 0, sizeof(outBuffer));
		sendLen = m_stm2038BImpl->setWorkMode(1, m_stm2038BImpl->workModes::ZEROPOINT_MODEING, outBuffer);

		//todo:发送给设备

		//电机使能
		memset(outBuffer, 0, sizeof(outBuffer));
		sendLen = m_stm2038BImpl->motorEnablement(1, outBuffer);

		//todo:发送给设备

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

}

void QmlCppBridge::onReceivedMsg(const QVariant& params)
{
    // 仅做基础类型检查后直接转发
    if (params.canConvert<QVariantMap>()) {
        emit sendtoQml(params); // 直接传递原始 QVariant
    }
}
