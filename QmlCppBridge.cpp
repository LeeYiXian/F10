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

	// 连接串口接收信号，处理设备返回数据
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
		QString chl = map["chl"].toString();
		int channel = (chl == "x") ? 0 : 1;  // x->0, y->1
		int wave = map["wave"].toInt();       // 波形：0-正弦,1-方波,2-三角,3-锯齿
		int peak = map["peak"].toInt();       // 峰峰值
		int rate = map["rate"].toInt();       // 频率
		int offset = map["offset"].toInt();   // 偏置

		// 组包（完全复刻MsPlatformImpl::sendSCVoltageHighSpeed逻辑）
		unsigned char packet[20];
		packet[0] = 0xAA;                     // 帧头
		packet[1] = (unsigned char)m_addr;    // 地址
		packet[2] = 0x14;                     // 数据长度
		packet[3] = 0x0C;                     // 命令码
		packet[4] = 0x00;                     // 保留位
		packet[5] = channel;                  // 通道号

		// 波形类型转换（Z/F/S/J对应0-3）
		switch (wave) {
		case 0: packet[6] = 'Z'; break;
		case 1: packet[6] = 'F'; break;
		case 2: packet[6] = 'S'; break;
		case 3: packet[6] = 'J'; break;
		default:
			qDebug() << "error wave type:" << wave;
			return;
		}

		// 峰峰值、频率、偏置转换（复用doubleToChar）
		unsigned char temp[4];
		doubleToChar(peak, temp);
		memcpy(packet + 7, temp, 4);          // 峰峰值(4字节)
		doubleToChar(rate, temp);
		memcpy(packet + 11, temp, 4);         // 频率(4字节)
		doubleToChar(offset, temp);
		memcpy(packet + 15, temp, 4);         // 偏置(4字节)

		// 计算校验位
		packet[19] = calcBit(packet, 19);

		// 通过SerialPort发送
		m_serialPort->sendData(QByteArray((const char*)packet, 20));
		qDebug() << "Sent high-speed packet to" << chl << "(20 bytes)";
		}
	else if (method == "shakingtable.close")
	{
		// 组包（复刻MsPlatformImpl::stopSCVoltageHighSpeed逻辑）
		unsigned char packet[6];
		packet[0] = 0xAA;                     // 帧头
		packet[1] = (unsigned char)m_addr;    // 地址
		packet[2] = 0x06;                     // 数据长度
		packet[3] = 0x0E;                     // 命令码
		packet[4] = 0x00;                     // 保留位

		// 计算校验位
		packet[5] = calcBit(packet, 5);

		// 通过SerialPort发送
		m_serialPort->sendData(QByteArray((const char*)packet, 6));
		qDebug() << "Sent stop packet (6 bytes)";
		}
		// 处理实时电压读取
	else if (method == "shakingtable.readVoltage") {
		QString chl = map["chl"].toString();
		int channel = (chl == "x") ? 0 : 1;
		int times = map["times"].toInt();     // 读取周期(ms)

		// 组包（复刻MsPlatformImpl::readSCVoltageRealTime逻辑）
		unsigned char packet[8];
		packet[0] = 0xAA;
		packet[1] = (unsigned char)m_addr;
		packet[2] = 0x08;                     // 数据长度
		packet[3] = 0x07;                     // 命令码
		packet[4] = 0x00;
		packet[5] = channel;                  // 通道号
		packet[6] = times;                    // 周期

		// 计算校验位
		packet[7] = calcBit(packet, 7);

		// 通过SerialPort发送
		m_serialPort->sendData(QByteArray((const char*)packet, 8));
		qDebug() << "Sent read voltage request to" << chl << "(8 bytes)";
	}
}

// 计算校验位（直接提取MsPlatformImpl::calcBit逻辑）
unsigned char QmlCppBridge::calcBit(const unsigned char* buffers, int len) {
	char cRet = 0x00;
	for (int i = 0; i < len; i++) {
		cRet = cRet ^ buffers[i];
	}
	qDebug() << "calcBit ret:" << (int)cRet;
	return cRet;
}

// double转字节数组（直接提取MsPlatformImpl::doubleToChar逻辑）
unsigned char* QmlCppBridge::doubleToChar(double fValue, unsigned char* kk) {
	if (fValue < 0) {
		fValue *= (-1);
		int a = int(fValue);
		kk[0] = a / 256 + 0x80;
		kk[1] = a % 256;
		a = int((fValue - a) * 10000);
		kk[2] = a / 256;
		kk[3] = a % 256;
	}
	else {
		int a = int(fValue);
		kk[0] = a / 256;
		kk[1] = a % 256;
		a = int((fValue - a + 0.000001) * 10000);
		kk[2] = a / 256;
		kk[3] = a % 256;
	}
	return kk;
}

// 字节数组转double（直接提取MsPlatformImpl::charToDouble逻辑）
double QmlCppBridge::charToDouble(char* kk) {
	double d;
	if (kk[0] & 0x80) {
		kk[0] -= 0x80;
		d = (double)(kk[0] * 256 + kk[1] + (kk[2] * 256 + kk[3]) * 0.0001);
		d *= (-1);
	}
	else {
		d = (double)(kk[0] * 256 + kk[1] + (kk[2] * 256 + kk[3]) * 0.0001);
	}
	return d;
}

void QmlCppBridge::updateXStatus(const QString& gear, const QString& run) {
	xGearStatus = gear;
	xRunStatus = run;

	QVariantMap result;
	result["method"] = "statusUpdate";
	result["target"] = "x";
	result["gear"] = xGearStatus;
	result["run"] = xRunStatus;
	emit sendtoQml(result);
}

void QmlCppBridge::updateYStatus(const QString& gear, const QString& run) {
	yGearStatus = gear;
	yRunStatus = run;

	QVariantMap result;
	result["method"] = "statusUpdate";
	result["target"] = "y";
	result["gear"] = yGearStatus;
	result["run"] = yRunStatus;
	emit sendtoQml(result);
}

void QmlCppBridge::updateDualAxisStatus(const QString& status) {
	dualAxisRunStatus = status;

	QVariantMap result;
	result["method"] = "statusUpdate";
	result["target"] = "dualAxis";
	result["status"] = dualAxisRunStatus;
	emit sendtoQml(result);
}

void QmlCppBridge::handleReceivedSerialData(const QByteArray& data)
{
	if (data.size() < 5 || (unsigned char)data[0] != 0xAA) {
		qDebug() << "Invalid device response (header or length error)";
		return;
	}

	// 解析电压数据（对应命令码0x07）
	if ((unsigned char)data[3] == 0x07) {
		if (data.size() < 10) {
			qDebug() << "Voltage data length error";
			return;
		}

		// 提取通道号和电压值
		int chl = (unsigned char)data[5];
		char volData[4] = { data[6], data[7], data[8], data[9] };
		double voltage = charToDouble(volData);

		// 转发给QML
		QVariantMap result;
		result["method"] = "shakingtable.voltage";
		result["channel"] = (chl == 0) ? "x" : "y";
		result["voltage"] = voltage;
		emit sendtoQml(result);
		qDebug() << "Received voltage from channel" << chl << ":" << voltage;
	}
	// 解析状态数据（假设命令码为0x08，具体根据实际情况调整）
	if ((unsigned char)data[3] == 0x08) {
		if (data.size() < 10) {
			qDebug() << "Status data length error";
			return;
		}

		int target = (unsigned char)data[5]; // 0: x轴, 1: y轴, 2: 双轴转台
		QString gear = QString::fromStdString(std::string((char*)data[6], 4));
		QString run = QString::fromStdString(std::string((char*)data[10], 4));

		if (target == 0) {
			updateXStatus(gear, run);
		}
		else if (target == 1) {
			updateYStatus(gear, run);
		}
		else if (target == 2) {
			updateDualAxisStatus(run);
		}
	}
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
