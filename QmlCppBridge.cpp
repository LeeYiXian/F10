#include "QmlCppBridge.h"
#include <QDebug>
#include <QCryptographicHash>
#include <QDateTime>
#include <QThread>
#include "LTDMC.h"
#include "Utils.h"
#include <QPixmap>
#include <QScreen>
#include <QGuiApplication>
#define MAX_SEND_BUFFER_SIZE 256

QmlCppBridge::QmlCppBridge(QObject * parent)
	: QObject(parent), m_ConnectNum(10), m_MCConnecState(false), m_MCEnableState(false)
{
	m_switchMechanismNetMgr = new NetworkManager();
	m_filterWheelNetMgr = new NetworkManager();
	m_wavePlateNetMgr = new NetworkManager();

	connect(this, &QmlCppBridge::sendtoSwitchMechanism, m_switchMechanismNetMgr, &NetworkManager::onSendData, Qt::QueuedConnection);
	connect(this, &QmlCppBridge::sendtoFilterWheel, m_filterWheelNetMgr, &NetworkManager::onSendData, Qt::QueuedConnection);
	connect(this, &QmlCppBridge::sendtoWavePlate, m_wavePlateNetMgr, &NetworkManager::onSendData, Qt::QueuedConnection);
	connect(m_switchMechanismNetMgr, &NetworkManager::socketReady, [=]() {
		m_switchMechanismNetMgr->connectToDevice(SWITCH_MECHANISM_IP, SWITCH_MECHANISM_PORT);
		});

	connect(m_filterWheelNetMgr, &NetworkManager::socketReady, [=]() {
		m_filterWheelNetMgr->connectToDevice(FILTER_WHEEL_IP, FILTER_WHEEL_PORT);
		});

	connect(m_wavePlateNetMgr, &NetworkManager::socketReady, [=]() {
		m_wavePlateNetMgr->connectToDevice(WAVE_PLATE_IP, WAVE_PLATE_PORT);
		});

	m_linearGuiderailImpl = new LinearGuideRailImpl();
	m_filterWheelImpl = new FilterWheelImpl();
	m_stm2038BImpl = new Stm2038bImpl();

	connect(m_switchMechanismNetMgr, &NetworkManager::dataReceived, this, &QmlCppBridge::handleReceivedNetworkData);
	connect(m_filterWheelNetMgr, &NetworkManager::dataReceived, this, &QmlCppBridge::handleReceivedNetworkData);
	connect(m_wavePlateNetMgr, &NetworkManager::dataReceived, this, &QmlCppBridge::handleReceivedNetworkData);

	// 连接串口接收信号，处理设备返回数据
    m_serialPort = new SerialPort();
	connect(m_serialPort, &SerialPort::connectionChanged, this, &QmlCppBridge::onConnectStatus);
	connect(m_serialPort, &SerialPort::dataReceived, this, &QmlCppBridge::handleReceivedSerialData);
	connect(this, &QmlCppBridge::sendSerialData, m_serialPort, &SerialPort::sendData);
	//connect(this, &QmlCppBridge::sendSerialData, m_serialPort, &SerialPort::sendData);
	m_serialPort->connectDevice(m_configManager.getCOM("COM"), m_configManager.getCOM("BaudRate").toInt());

	//伺服类
	m_servoUdp = new ServoUdp(LOCAL_PORT,QHostAddress(SERVO_IP),SERVO_PORT,this);
	connect(m_servoUdp, &ServoUdp::received, this, &QmlCppBridge::handleReceivedServoData);

	// 心跳定时器初始化，但不启动
	m_heartbeatTimer.setInterval(1000 / 7); // 7Hz -> ~142ms
	connect(&m_heartbeatTimer, &QTimer::timeout, this, &QmlCppBridge::sendHeartbeat);
	m_heartbeatTimer.start();
	
	//运动初始化
	for (int i = 0; i < AXISNUM; i++)
	{
		pAxis[i] = NULL;
	}

	connect(this, &QmlCppBridge::sgnDmcInit, this, &QmlCppBridge::onDmcInit);
	emit sgnDmcInit();

	QThread* thread = new QThread();
	auto worker = [=]() {
		char outBuffer[MAX_SEND_BUFFER_SIZE] = { 0 };
		int sendLen;
		while (true)
		{
			//切换机构状态查询&心跳包
			sendLen = m_linearGuiderailImpl->getMotorStatus(1, outBuffer);
			emit sendtoSwitchMechanism(QByteArray(outBuffer, sendLen));
			if (--m_switchMissCount < 0) {
				m_switchMissCount = 0; // 避免负数
				if (m_switchOnline)
				{
					m_switchOnline = false;
					QVariantMap map;
					map["method"] = "switchmechanism.offline";
					emit sendtoQml(map);
				}
			}

			//滤光轮状态查询
			static bool MoterPosition = true;
			if (MoterPosition)
			{
				memset(outBuffer, 0, MAX_SEND_BUFFER_SIZE);
				sendLen = m_filterWheelImpl->readMotorPosition(1, outBuffer);
				emit sendtoFilterWheel(QByteArray(outBuffer, sendLen));
			}
			else
			{
				memset(outBuffer, 0, MAX_SEND_BUFFER_SIZE);
				sendLen = m_filterWheelImpl->getMotorStatus(1, outBuffer);
				emit sendtoFilterWheel(QByteArray(outBuffer, sendLen));
			}
			
			if (--m_filterMissCount < 0)
			{
				m_filterMissCount = 0; // 避免负数
				if (m_filterOnline)
				{
					m_filterOnline = false;
					QVariantMap map;
					map["method"] = "filterwheel.offline";
					emit sendtoQml(map);
				}
			}

			if (MoterPosition)
			{
				//波片状态查询
				memset(outBuffer, 0, MAX_SEND_BUFFER_SIZE);
				sendLen = m_stm2038BImpl->readMotorPosition(1, outBuffer);
				emit sendtoWavePlate(QByteArray(outBuffer, sendLen));
			}
			else
			{
				//波片电机状态查询
				memset(outBuffer, 0, MAX_SEND_BUFFER_SIZE);
				sendLen = m_stm2038BImpl->getMotorStatus(1, outBuffer);
				emit sendtoWavePlate(QByteArray(outBuffer, sendLen));
			}

			if (--m_waveMissCount < 0)
			{
				m_waveMissCount = 0; // 避免负数
				if (m_waveOnline)
				{
					m_waveOnline = false;
					QVariantMap map;
					map["method"] = "waveplate.offline";
					emit sendtoQml(map);
				}
			}

			MoterPosition = !MoterPosition;


			/* {
				unsigned char packet[7];
				packet[0] = 0xAA;
				packet[1] = 0x01;
				packet[2] = 0x07;                     // 数据长度
				packet[3] = 0x05;                     // 命令码
				packet[4] = 0x00;                     // 
				packet[5] = 0x00;
				packet[6] = calcBit(packet, 6);

				// 通过SerialPort发送
				emit sendSerialData(QByteArray((const char*)packet, 7));
			}

			{
				unsigned char packet[7];
				packet[0] = 0xAA;
				packet[1] = 0x01;
				packet[2] = 0x07;                     // 数据长度
				packet[3] = 0x05;                     // 命令码
				packet[4] = 0x00;                     // 
				packet[5] = 0x01;
				packet[6] = calcBit(packet, 6);

				// 通过SerialPort发送
				emit sendSerialData(QByteArray((const char*)packet, 7));
			}
			*/

			{
				unsigned char packet[7];
				packet[0] = 0xAA;
				packet[1] = 0x01;
				packet[2] = 0x07;                     // 数据长度
				packet[3] = 0x06;                     // 命令码
				packet[4] = 0x00;                     // 
				packet[5] = 0x00;
				packet[6] = calcBit(packet, 6);

				// 通过SerialPort发送
				emit sendSerialData(QByteArray((const char*)packet, 7));
			}

			{
				unsigned char packet[7];
				packet[0] = 0xAA;
				packet[1] = 0x01;
				packet[2] = 0x07;                     // 数据长度
				packet[3] = 0x06;                     // 命令码
				packet[4] = 0x00;                     // 
				packet[5] = 0x01;
				packet[6] = calcBit(packet, 6);

				// 通过SerialPort发送
				emit sendSerialData(QByteArray((const char*)packet, 7));
			}

			//查询各轴位置
			QureyAxisStatus();
			
			QThread::msleep(500);
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

	auto sendToDevice = [&](auto netMgr, auto action, auto signalFunc) {
		memset(outBuffer, 0, sizeof(outBuffer));
		sendLen = action();
		QByteArray data(outBuffer, sendLen);
		LX_LOG_INFO("Send data to %s", data.toHex().toStdString().c_str());
		(this->*signalFunc)(data);
		//emit signalFunc;
	};

	if (method == "switchmechanism.open") {
		LX_LOG_INFO("SwitchMechanism open");
		sendToDevice(m_switchMechanismNetMgr, [&] {
			return m_linearGuiderailImpl->moveByStep(1, -900000, outBuffer);
		}, & QmlCppBridge::sendtoSwitchMechanism);
	}
	else if (method == "switchmechanism.close") {
		LX_LOG_INFO("SwitchMechanism close");
		sendToDevice(m_switchMechanismNetMgr, [&] {
			return m_linearGuiderailImpl->moveByStep(1, 900000, outBuffer);
		}, & QmlCppBridge::sendtoSwitchMechanism);
	}
	else if (method == "switchmechanism.findzero") {
		//暂不支持寻零，寻零直接运行到负向限位开关
		LX_LOG_INFO("SwitchMechanism findzero");
		sendToDevice(m_switchMechanismNetMgr, [&] {
			return m_linearGuiderailImpl->motorZeroing(1, outBuffer);
		}, & QmlCppBridge::sendtoSwitchMechanism);
	}

	else if (method == "filterwheel.setgear") {
		int index = map["value"].toInt();
		LX_LOG_INFO("FilterWheel set gear to %d", index);
		static const QMap<int, int> gearMap = {
			{0, 2132}, {1, 1106}, {2, 6396}, {3, 3189}, {4, 4264}
		};

		QThread* thread = new QThread();
		QObject::connect(thread, &QThread::started, [=]{

			char outBuffer[MAX_SEND_BUFFER_SIZE] = { 0 };
			if (!gearMap.contains(index)) {
				qDebug() << "Invalid filter wheel index";
				thread->quit();
				return;
			}

			int sendLen = m_filterWheelImpl->motorZeroing(1, outBuffer);
			emit sendtoFilterWheel(QByteArray(outBuffer, sendLen));

			QThread::msleep(8000);
            memset(outBuffer, 0, sizeof(outBuffer));
            sendLen = m_filterWheelImpl->setZeroing(1, outBuffer);
            emit sendtoFilterWheel(QByteArray(outBuffer, sendLen));

			QThread::msleep(100);

			memset(outBuffer, 0, sizeof(outBuffer));
			sendLen = m_filterWheelImpl->moveByStep(1, gearMap[index], outBuffer);
			emit sendtoFilterWheel(QByteArray(outBuffer, sendLen));

			QThread::msleep(6000);
			thread->quit();
			});

		QObject::connect(thread, &QThread::finished, thread, &QThread::deleteLater);
		thread->start();
	}
	else if (method == "waveplate.open") {
		LX_LOG_INFO("WavePlate open");
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->setContorMode(1, outBuffer); }, &QmlCppBridge::sendtoWavePlate);
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->setWorkMode(1, m_stm2038BImpl->workModes::POSITION_CONTROL, outBuffer); }, &QmlCppBridge::sendtoWavePlate);
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->setTargetSpeed(1, 10000, outBuffer); }, &QmlCppBridge::sendtoWavePlate);
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->setTargetPosition(1, 19529, outBuffer); }, &QmlCppBridge::sendtoWavePlate);//位置写死
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->motorReady(1, outBuffer); }, &QmlCppBridge::sendtoWavePlate);
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->motorDisablement(1, outBuffer); }, &QmlCppBridge::sendtoWavePlate);
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->moveToSetPosition(1, 1600, outBuffer); }, &QmlCppBridge::sendtoWavePlate);
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->stopRunning(1, outBuffer); }, &QmlCppBridge::sendtoWavePlate);
	}
	else if (method == "waveplate.close") {
		LX_LOG_INFO("WavePlate close");
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->setContorMode(1, outBuffer); }, &QmlCppBridge::sendtoWavePlate);
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->setWorkMode(1, m_stm2038BImpl->workModes::POSITION_CONTROL, outBuffer); }, &QmlCppBridge::sendtoWavePlate);
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->setTargetSpeed(1, 10000, outBuffer); }, &QmlCppBridge::sendtoWavePlate);
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->setTargetPosition(1, 88357, outBuffer); }, &QmlCppBridge::sendtoWavePlate);//位置写死
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->motorReady(1, outBuffer); }, &QmlCppBridge::sendtoWavePlate);
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->motorDisablement(1, outBuffer); }, &QmlCppBridge::sendtoWavePlate);
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->moveToSetPosition(1, 1600, outBuffer); }, &QmlCppBridge::sendtoWavePlate);
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->stopRunning(1, outBuffer); }, &QmlCppBridge::sendtoWavePlate);
	}
	else if (method == "waveplate.findzero") {//暂不支持
		LX_LOG_INFO("WavePlate findzero");
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->setContorMode(1, outBuffer); }, &QmlCppBridge::sendtoWavePlate);
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->setWorkMode(1, m_stm2038BImpl->workModes::ZEROPOINT_MODEING, outBuffer); }, &QmlCppBridge::sendtoWavePlate);
		sendToDevice(m_wavePlateNetMgr, [&] { return m_stm2038BImpl->motorEnablement(1, outBuffer); }, &QmlCppBridge::sendtoWavePlate);
	}

	// 升降台逻辑处理
	else if (method == "supportplatform.enable") //升降台使能
	{
		
		if (!m_MCConnecState) {
			LX_LOG_ERR("连接运动控制器失败，使能失败");
			// todo: 显示设备未连接
			return;
		}

		QString targetStr = map["target"].toString();
		LX_LOG_INFO("Enable axis: %s", targetStr.toStdString().c_str());

		AxisTarget target = stringToAxisTarget(targetStr);
		AxisClass* pAxisObj = getAxisByTarget(target, targetStr);

		if (pAxisObj) {
			pAxisObj->enableAxis(true);
		}
		else
		{
			LX_LOG_ERR("Unknown axis target: %s", targetStr.toStdString().c_str());
			return;
		}
	}

	else if (method == "supportplatform.unable") //升降台失能
	{
		if (!m_MCConnecState) {
			LX_LOG_ERR("连接运动控制器失败，使能失败");
			// todo: 显示设备未连接
			return;
		}

		QString targetStr = map["target"].toString();
		LX_LOG_INFO("Unable axis: %s", targetStr.toStdString().c_str());

		AxisTarget target = stringToAxisTarget(targetStr);
		AxisClass* pAxisObj = getAxisByTarget(target, targetStr);

		if (pAxisObj) {
			pAxisObj->enableAxis(false);
		}
		else
		{
			LX_LOG_ERR("Unknown axis target: %s", targetStr.toStdString().c_str());
			return;
		}
	}

	else if (method == "supportplatform.stop") //升降台停止
	{
		QString targetStr = map["target"].toString();
		LX_LOG_INFO("Stop axis: %s", targetStr.toStdString().c_str());

		AxisTarget target = stringToAxisTarget(targetStr);
		AxisClass* pAxisObj = getAxisByTarget(target, targetStr);

		if (pAxisObj) {
			pAxisObj->StopMove();
		}
		else
		{
			LX_LOG_ERR("Unknown axis target: %s", targetStr.toStdString().c_str());
			return;
		}
	}


	else if (method == "supportplatform.forward") //升降台前进
	{
		QString targetStr = map["target"].toString();
		
		double dSpeed = map["speed"].toDouble();
		Limit myLimit = { 0 };

		LX_LOG_INFO("Forward axis: %s, speed: %f", targetStr.toStdString().c_str(), dSpeed);

		AxisTarget target = stringToAxisTarget(targetStr);
		AxisClass* pAxisObj = getAxisByTarget(target, targetStr);
		if (!pAxisObj)
		{
			LX_LOG_ERR("Unknown axis target: %s", targetStr.toStdString().c_str());
			return;
		}

		pAxisObj->startMoveRealTime(dSpeed, Negative);//设置运动方向和距离
	}
	else if (method == "supportplatform.backward") //升降台后退
	{
		QString targetStr = map["target"].toString();

		double dSpeed = map["speed"].toDouble();
		Limit myLimit = { 0 };

		LX_LOG_INFO("Backward axis: %s, speed: %f", targetStr.toStdString().c_str(), dSpeed);

		AxisTarget target = stringToAxisTarget(targetStr);
		AxisClass* pAxisObj = getAxisByTarget(target, targetStr);
		if (!pAxisObj)
		{
			LX_LOG_ERR("Unknown axis target: %s", targetStr.toStdString().c_str());
			return;
		}

		pAxisObj->startMoveRealTime(dSpeed, Positive);//设置运动方向和距离
	}
	else if (method == "supportplatform.position") //升降台目标位置
	{
		QString targetStr = map["target"].toString();
		double dDistance = map["position"].toDouble();
		double dSpeed = map["speed"].toDouble();

        if (targetStr == "platform.height")
        {
            dDistance -= 1400;
        }

		LX_LOG_INFO("Position axis: %s, position: %f, speed: %f", targetStr.toStdString().c_str(), dDistance, dSpeed);

		AxisTarget target = stringToAxisTarget(targetStr);
		AxisClass* pAxisObj = getAxisByTarget(target, targetStr);
		if (!pAxisObj)
		{
			LX_LOG_ERR("Unknown axis target: %s", targetStr.toStdString().c_str());
			return;
		}
		pAxisObj->setDeviceSpeed(dSpeed);//设置速度
		pAxisObj->startMovDistance(dDistance, ABSOLUTE_COORDINATE_MODE);
	}

	//微震动台x轴
	else if (method == "shakingtable.open")
	{
		QString chl = map["chl"].toString();
		int channel = (chl == "x") ? 0 : (chl == "y"? 1 : 2);  // x->0, y->1, z->2
		int wave = map["wave"].toInt();       // 波形：0-正弦,1-方波,2-三角,3-锯齿
		int peak = map["peak"].toInt();       // 峰峰值
		int position = map["position"].toInt();
		int freq = map["freq"].toInt();       // 频率
		int mode = map["mode"].toInt();
		int offset = peak/2;   // 偏置

		unsigned char packet[20];

		if (0 == mode)
		{
            packet[0] = 0xAA;                     // 帧头
            packet[1] = 0x01;    // 地址
            packet[2] = 0x14;                     // 数据长度
            packet[3] = 0x0F;                     // 命令码
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
            doubleToChar(freq, temp);
            memcpy(packet + 11, temp, 4);         // 频率(4字节)
            doubleToChar(offset, temp);
            memcpy(packet + 15, temp, 4);         // 偏置(4字节)

            // 计算校验位
            packet[19] = calcBit(packet, 19);
			m_serialPort->sendData(QByteArray((const char*)packet, 20));
		}
		else if(1 == mode)
		{
            packet[0] = 0xAA;                     // 帧头
            packet[1] = 0x01;    // 地址
            packet[2] = 0x0B;                     // 数据长度
            packet[3] = 0x01;                     // 命令码
            packet[4] = 0x00;                     // 保留位
            packet[5] = channel;                  // 通道号

            unsigned char temp[4];
            doubleToChar(position, temp);
            memcpy(packet + 6, temp, 4);          // 峰峰值(4字节)

            // 计算校验位
            packet[10] = calcBit(packet, 10);
            m_serialPort->sendData(QByteArray((const char*)packet, 11));
		}

		LX_LOG_INFO("ShakingTable open, chl: %s, wave: %d, peak: %d, freq: %d, offset: %d", chl.toStdString().c_str(), wave, peak, freq, offset);

		// 组包（完全复刻MsPlatformImpl::sendSCVoltageHighSpeed逻辑）
		
		

		// 通过SerialPort发送
		
		//qDebug() << "Sent high-speed packet to" << chl << "(20 bytes)";
	}
	else if (method == "shakingtable.close")
	{
		// 组包（复刻MsPlatformImpl::stopSCVoltageHighSpeed逻辑）
		unsigned char packet[7];
		packet[0] = 0xAA;                     // 帧头
		packet[1] = 0x01;    // 地址
		packet[2] = 0x07;                     // 数据长度
		packet[3] = 0x11;                     // 命令码
		packet[4] = 0x00;                     // 保留位

		QString chl = map["chl"].toString();

		LX_LOG_INFO("ShakingTable close, chl: %s", chl.toStdString().c_str());

		int channel = (chl == "x") ? 0 : (chl == "y" ? 1 : 2);  // x->0, y->1, z->2
		packet[5] = channel;                  // 通道号
		// 计算校验位
		packet[6] = calcBit(packet, 6);

		// 通过SerialPort发送
		m_serialPort->sendData(QByteArray((const char*)packet, 7));
		qDebug() << "Sent stop packet (6 bytes)";
	}


	//伺服下发前置数据
	else if (method == "servo.setmode")
	{
		// mode 是一个字节，比如 0x00, 0x10, 0x20, 0x30
		int mode = map["value"].toInt();

		LX_LOG_INFO("Set servo mode: %d", mode);

		// 组protobuf包
		TtbSet msg;
		msg.set_operation(TtbOperation::TTB_MODE);
		msg.set_set_mode(TtbMode(mode));
		msg.set_hb(m_hbCount++);
		//UDP发送
		m_servoUdp->send(serializeMessage(msg));
	}
	else if (method == "servo.setvel")
	{
		TtbSet msg;
		msg.set_operation(TtbOperation::TTB_SET_VEL);

		QVariant valueVar = map["value"];
		QVariantMap velMap = valueVar.toMap();
		float vx = velMap.value("x").toFloat();
		float vy = velMap.value("y").toFloat();

		QVariant valueVarAcc = map["acc"];
		QVariantMap accMap = valueVarAcc.toMap();
		float vx_acc = accMap.value("x").toFloat();
		float vy_acc = accMap.value("y").toFloat();

		LX_LOG_INFO("Set servo velocity: x: %f, y: %f", vx, vy);

		// 填充 set_vel
		TtbSetVel* vel = msg.mutable_set_vel();
		vel->set_vel_x(vx);
		vel->set_vel_y(vy);

		vel->set_acc_x(vx_acc);
		vel->set_acc_y(vy_acc);

		msg.set_hb(m_hbCount++);
		// UDP发送
		m_servoUdp->send(serializeMessage(msg));
	}
	else if (method == "servo.setposx")
	{
		TtbSet msg;
		msg.set_operation(TtbOperation::TTB_SET_POS_X);

		double pos = map["value"].toDouble();
		double vel = map["vel"].toDouble();
		double acc = map["acc"].toDouble();

		LX_LOG_INFO("Set servo position x: %f", pos);

		// 填充 set_pos_x
		TtbSetPos* posx = msg.mutable_set_pos_x();
		posx->set_pos(pos);
		posx->set_pos_max_vel(vel);
		posx->set_pos_max_acc(acc);
		msg.set_hb(m_hbCount++);
		// UDP发送
		m_servoUdp->send(serializeMessage(msg));
	}
	else if (method == "servo.setposy")
	{
		TtbSet msg;
		msg.set_operation(TtbOperation::TTB_SET_POS_Y);

		double pos = map["value"].toDouble();
		double vel = map["vel"].toDouble();
		double acc = map["acc"].toDouble();

		LX_LOG_INFO("Set servo position y: %f", pos);

		// 填充 set_pos_x
		TtbSetPos* posx = msg.mutable_set_pos_y();
		posx->set_pos(pos);
		posx->set_pos_max_vel(vel);
		posx->set_pos_max_acc(acc);
		msg.set_hb(m_hbCount++);
		// UDP发送
		m_servoUdp->send(serializeMessage(msg));
	}

	else if (method == "software.openfsm")
	{
		LX_LOG_INFO("Open FastMirrorController");
		QString qpath = m_configManager.getProgramPath("FastMirrorController");
		// 转换为 std::wstring
		std::wstring wpath = qpath.toStdWString();
		//变量，通过配置文件 赋值
		m_processLauncher.launch(wpath);
	}
	else if (method == "software.opengpm")
	{
		LX_LOG_INFO("Open PolarizationAnalyzer");
		QString qpath = m_configManager.getProgramPath("PolarizationAnalyzer");
		// 转换为 std::wstring
		std::wstring wpath = qpath.toStdWString();
		//变量，通过配置文件 赋值
		m_processLauncher.launch(wpath);
	}
	else if (method == "software.openqcm")
	{
		LX_LOG_INFO("Open BeamQualityAnalyzer");
		QString qpath = m_configManager.getProgramPath("BeamQualityAnalyzer");
		// 转换为 std::wstring
		std::wstring wpath = qpath.toStdWString();
		//变量，通过配置文件 赋值
		m_processLauncher.launch(wpath);
	}
}

void QmlCppBridge::sendHeartbeat() {
	TtbSet msg;
	msg.set_operation(TtbOperation::TTB_NO_CMD);
	msg.set_hb(m_hbCount++);
	// UDP发送
	m_servoUdp->send(serializeMessage(msg));
}

// 计算校验位（直接提取MsPlatformImpl::calcBit逻辑）
unsigned char QmlCppBridge::calcBit(const unsigned char* buffers, int len) {
	char cRet = 0x00;
	for (int i = 0; i < len; i++) {
		cRet = cRet ^ buffers[i];
	}
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
double QmlCppBridge::charToDouble(unsigned char* kk) {
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

	QVariantMap result;
	result["method"] = "shakingtable.online";
	emit sendtoQml(result);

	/*
	// 解析电压数据（对应命令码0x05）
	if ((unsigned char)data[3] == 0x05) {
		//提取通道号
		int channel = (int)data[5];

		// 提取电压值
		char volDatax[4] = { data[6], data[7], data[8], data[9] };
		double voltagex = charToDouble(volDatax);
		// 转发给QML
		QVariantMap result;
		result["method"] = "shakingtable.voltage";
		result["chl"] = channel;
		result["voltage"] = voltagex;
		emit sendtoQml(result);
	}
	*/

	if ((unsigned char)data[3] == 0x06) {
		// 提取通道号
		int channel = (int)data[5];

		// 提取位移值
		unsigned char posDatax[4] = { data[6], data[7], data[8], data[9] };
		double posx = charToDouble(posDatax);

		// 转发给QML
		QVariantMap result;
		result["method"] = "shakingtable.position";
		result["chl"] = channel;
		result["position"] = posx;
		emit sendtoQml(result);
	}
	
}

void QmlCppBridge::handleReceivedNetworkData(const QByteArray& data, const QByteArray& cmd)
{
	//判断信号来自哪个sender
	QObject* sender = QObject::sender();

    int dataLen = data.length();
	if (dataLen > 256)
	{
        return; // 数据长度超过限制，直接返回
	}
	LX_LOG_INFO("Received data %s, length: %d", data.toHex().data(), dataLen);
	char buffer[256] = {0};
    for (int i = 0; i < dataLen; i++)
    {
        buffer[i] = data[i];
    }

	if (sender == m_switchMechanismNetMgr)
	{
		//todo:处理接收到的切换机构数据
		sLinearOutData parseData;

		m_linearGuiderailImpl->dataParse(buffer, dataLen, &parseData, 0);

		if (parseData.functionId == 0x03)//电机状态
		{
			QVariantMap result;
			result["method"] = "switchmechanism.status";
			
			switch (parseData.otherStatus)
			{
			case 1:
				result["gear"] = QStringLiteral("复位状态出错");
				break;
			case 3:
				result["gear"] = QStringLiteral("启用");
				break;
			case 2:
				result["gear"] = QStringLiteral("禁用");
				break;
			default:
				result["gear"] = QStringLiteral("其他");
				break;
			}

			switch (parseData.runningStatus)
			{
			case 1:
				result["motorStatus"] = QStringLiteral("空闲状态");
				break;
			case 2:
				result["motorStatus"] = QStringLiteral("运行中");
				break;
			default:
				result["motorStatus"] = QStringLiteral("未知状态");
				break;
			}

			emit sendtoQml(result);
		}
		m_switchMissCount++;
		if (!m_switchOnline)
		{
			m_switchOnline = true;
			QVariantMap map;
			map["method"] = "switchmechanism.online";
			emit sendtoQml(map);
			m_switchMissCount = 3;
		}
	}
	else if (sender == m_filterWheelNetMgr)
	{
		//todo:处理接收到的滤光轮数据
        sFilterOutData filterData;

        m_filterWheelImpl->dataParse(buffer, dataLen, &filterData);

		QVariantMap result;
		result["method"] = "filterwheel.status";

		// 处理电机状态
		if (filterData.registerAddr == 0) // 读电机状态
		{
			switch (filterData.getValue)
			{
			case 0:
				result["motorStatus"] = QStringLiteral("到达位置");
				break;
			case 1:
				result["motorStatus"] = QStringLiteral("正在运行");
				break;
			case 2:
				result["motorStatus"] = QStringLiteral("碰撞停");
				break;
			case 3:
			case 4:
				result["motorStatus"] = QStringLiteral("到达限位");
				break;
			default:
				result["motorStatus"] = QStringLiteral("未知状态");
				break;
			}
		}
		// 处理电机档位

		else if (filterData.registerAddr == 1) // 电机位置
		{
			if (std::abs(filterData.getValue - 2132) < 20)
				result["gear"] = QStringLiteral("空挡");
			else if (std::abs(filterData.getValue - 1106) < 20)
				result["gear"] = QStringLiteral("发1540.56 收1563.05");
			else if (std::abs(filterData.getValue - 6396) < 20)
				result["gear"] = QStringLiteral("发1545.32 收1559.79");
			else if (std::abs(filterData.getValue - 3189) < 20)
				result["gear"] = QStringLiteral("发1559.79 收1545.32");
			else if (std::abs(filterData.getValue - 4264) < 20)
				result["gear"] = QStringLiteral("发1563.05 收1540.56");
			else
				result["gear"] = QStringLiteral("未知档位");
		}

		emit sendtoQml(result);

		m_filterMissCount++;
		if (!m_filterOnline)
		{
			m_filterOnline = true;
			QVariantMap map;
			map["method"] = "filterwheel.online";
			emit sendtoQml(map);
			m_filterMissCount = 3;
		}
	}
	else if (sender == m_wavePlateNetMgr)
	{
		// 处理接收到的波片数据
		s2038OutData waveData;
		m_stm2038BImpl->dataParse(buffer, dataLen, &waveData, 0);

		QVariantMap result;
		result["method"] = "waveplate.status";

		// 电机位置
		if (waveData.functionId == 0x04) // 电机位置
		{
			if (std::abs(waveData.getValue - 19529) < 100)
				result["gear"] = QStringLiteral("左旋");
			else if (std::abs(waveData.getValue - 88357) < 100)
				result["gear"] = QStringLiteral("右旋");
			else
				result["gear"] = QStringLiteral("未知位置");
		}
		// 电机状态
		else if (waveData.functionId == 0x03) // 电机状态
		{
			switch (waveData.positionStatus)
			{	
			case 1:
				result["motorStatus"] = QStringLiteral("定位完成");
				break;
			case 2:
				result["motorStatus"] = QStringLiteral("正在定位");
				break;
			default:
				result["motorStatus"] = QStringLiteral("未知状态");
				break;
			}
		}
		emit sendtoQml(result);

		m_waveMissCount++;
		if (!m_waveOnline)
		{
			m_waveOnline = true;
			QVariantMap map;
			map["method"] = "waveplate.online";
			emit sendtoQml(map);
			m_waveMissCount = 3;
		}
	}
}

void  QmlCppBridge::handleReceivedServoData(const QByteArray& data)
{
	TtbRe reportMsg;

	if (!reportMsg.ParseFromArray(data.constData(), data.size())) {
		return;
	}

	// 基本信息
	uint64_t runCount = reportMsg.run_count();
	TtbMode currentMode = reportMsg.now_ttb_mode();

	// 角度/速度
	double angleX = reportMsg.get_ttb_angle_x();
	double angleY = reportMsg.get_ttb_angle_y();
	float velX = reportMsg.get_ttb_vel_x();
	float velY = reportMsg.get_ttb_vel_y();

	auto state = reportMsg.state();

	QVariantMap report;
	report["method"] = "servo.report";
	//report["runCount"] = runCount;
	report["currentMode"] = (int)currentMode;
	report["angleX"] = angleX;
	report["angleY"] = angleY;
	report["statusCode"] = state.err_code();
	emit sendtoQml(report);
}

void QmlCppBridge::ConfigAxis(int i, AxisClass* pAxis)
{
	if (pAxis == nullptr)
	{
		LX_LOG_ERR("传入的AxisClass指针为空，无法进行配置");
		//todo:弹出错误提示框
		return;
	}
	AxisParam mAxisParam;
	pAxis->getDeviceParams(mAxisParam);
	mAxisParam.dEquiv = dEquivs[i]; //设置脉冲当量	
	mAxisParam.nMinlimit = limits[i].minlimit;//设置最小值
	mAxisParam.nMaxlimit = limits[i].maxlimit;//设置最大值
	if (mAxisParam.nMinlimit >= mAxisParam.nMaxlimit)
	{
		mAxisParam.nMinlimit = mAxisParam.nMaxlimit;
		//todo:弹出错误提示框
	}
	pAxis->setDeviceParams(mAxisParam);
	pAxis->printAllParams();
}

void QmlCppBridge::DmcInit()
{
	WORD wCardNum = 0;
	WORD arrwCardList[10] = { 0 };
	DWORD arrdwCardTypeList[10] = { 0 };
	m_strIPAdress = RACE_CONTROLLER_IP;//现场待定
	if (dmc_board_init_eth(m_ConnectNum, (const char*)m_strIPAdress.toStdString().c_str()))//此处不能够频繁调用，TODO
	{
		LX_LOG_ERR("Connect %d IPAdress %s  Error", m_ConnectNum, m_strIPAdress.toStdString().c_str());
		m_MCConnecState = false;
		emit sgnDmcInit(); //重新初始化
		return;
	}
	else
	{
		m_MCConnecState = true;
	}

	if (m_MCConnecState)
	{
		//todo: 设备状态解析
		QVariantMap map;
		map["method"] = "dmc.online";
		emit sendtoQml(map);
	}
	else
	{
		//todo: 设备连接失败
		QVariantMap map;
		map["method"] = "dmc.offline";
		emit sendtoQml(map);
	}

	dmc_get_CardInfList(&wCardNum, arrdwCardTypeList, arrwCardList);    //获取正在使用的卡号列表
	m_wCard = arrwCardList[0];//轴数目
	for (DWORD i = 0; i < AXISNUM; i++) // 创建4个AxisClass对象并根据二维数组设置名称
	{
		AxisClass* pAxisObj = pAxis[i];
		if (pAxisObj == NULL)
		{
			pAxisObj = new AxisClass(m_ConnectNum, m_wCard, i);
			pAxis[i] = pAxisObj;
		}

		ConfigAxis(i, pAxisObj);
		pAxisObj->setDeviceName(deviceInfo[i][1]);
		pAxisObj->setDevicemCard(m_wCard);
		pAxisObj->setposition_unit();
		pAxisObj->startSeteEuiv();
		pAxisObj->setDeviceSpeed(DefaultSpeed[i]);
		pAxisObj->setMCLimit();
	}
}

void QmlCppBridge::DmcDistory()
{
	for (DWORD i = 0; i < AXISNUM; i++)
	{
		AxisClass* pAxisObj = pAxis[i];
		if (pAxisObj != NULL)
		{
			delete pAxisObj;
			pAxisObj = NULL;
		}
	}
	dmc_board_close();
}

void QmlCppBridge::QureyAxisStatus()
{
	//todo: 循环获取各轴状态并更新QML界面
	//step1 获取各轴状态
	for (int i = 0; i < AXISNUM; i++)
	{
		if (pAxis[i] == NULL)
			return;
		AxisClass* axis = pAxis[i];
		double Absolutepos = 0;
		double unitepos2 = 0;
		short  ret = axis->getAbsolutePos(Absolutepos);//获取轴的绝对位置 ->总线读取
		dmc_get_position_unit(axis->getDevicemCard(), axis->getDevicemmAxis(), &unitepos2); //获取轴的位置 开机后读取
		if (abs(unitepos2 - Absolutepos) > 0.001 && ret == 0)//同步相对位置和绝对位置
		{
			//伺服电机			
			if (!axis->getsynPosflag())//未同步
			{
				axis->setsynPosflag(true);//设置同步标志 仅同步一次
				dmc_set_position_unit(axis->getDevicemCard(), axis->getDevicemmAxis(), Absolutepos);
				LX_LOG_INFO("dmc_set_position_unit axis[%d] Abs pos[%f] unit unitepos2[%f] ",
					axis->getDevicemmAxis(), Absolutepos, unitepos2);
			}
			LX_LOG_ERR("axis[%d] Abs pos[%f] - unit unitepos2[%f] > 0.001",
				axis->getDevicemmAxis(), Absolutepos, unitepos2);
		}
		WORD usErrCode = 0;
		nmc_get_axis_errcode(axis->getDevicemCard(), axis->getDevicemmAxis(), &usErrCode);//设备错误
		if (usErrCode != 0)
		{
			short ret = nmc_clear_axis_errcode(axis->getDevicemCard(), axis->getDevicemmAxis());
			LX_LOG_INFO("AxixName[%s] 轴错误  errCode[%d] 自动清除错误 返回值[%d]", axis->getDeviceName().toStdString().c_str(), usErrCode, ret);
			
			//todo:弹出错误提示框
			QVariantMap map;
			map["method"] = "dmc.offline";
			emit sendtoQml(map);

			if (m_MCConnecState)
			{
				m_MCConnecState = !m_MCConnecState;
				emit sgnDmcInit(); //重新初始化
			}
		}
		
		// 电机状态获取
		bool moveState = axis->getMoveState();

		//todo: 轴状态更新
		QVariantMap result;
		result["method"] = "axisStatusUpdate";
		result["axis"] = i;
		result["moveState"] = moveState;
		result["position"] = Absolutepos;
		result["error"] = usErrCode;

		emit sendtoQml(result);
	}
}

AxisClass* QmlCppBridge::getAxisByTarget(AxisTarget target, const QString& targetStr)
// 根据目标类型获取轴对象，同时进行有效性检查
{
	int axisIndex = -1;
	switch (target) {
	case AxisTarget::X:      axisIndex = 0; break;
	case AxisTarget::Y:      axisIndex = 1; break;
	case AxisTarget::Z:      axisIndex = 2; break;
	case AxisTarget::Height: axisIndex = 3; break;
	default: {
		LX_LOG_ERR("Unknown axis target: %s", targetStr.toStdString().c_str());
		return nullptr;
	}
	}

	// 检查轴索引有效性（假设pAxis是类成员数组且已初始化）
	if (axisIndex < 0 || axisIndex >= 4) {
		LX_LOG_ERR("Invalid axis index for target: %s", targetStr.toStdString().c_str());
		return nullptr;
	}

	return pAxis[axisIndex];
}

void QmlCppBridge::onConnectStatus(bool status)
{
	if (status)
	{
		QVariantMap result;
		result["method"] = "shakingtable.online";
		emit sendtoQml(result);
	}
	else
	{
		QVariantMap result;
		result["method"] = "shakingtable.offline";
		emit sendtoQml(result);
	}
}

void QmlCppBridge::onReceivedMsg(const QVariant& params)
{
    // 仅做基础类型检查后直接转发
    if (params.canConvert<QVariantMap>()) {
        emit sendtoQml(params); // 直接传递原始 QVariant
    }
}

void QmlCppBridge::onDmcInit()
{
	QThread* workerThread = QThread::create([this]() {
		DmcInit();
	});
	connect(workerThread, &QThread::finished, workerThread, &QObject::deleteLater);
	workerThread->start();
}

void QmlCppBridge::onScreenShot()
{
	QScreen* screen = QGuiApplication::primaryScreen();
	if (screen) {
		QPixmap pixmap = screen->grabWindow(0); // 0 = 全屏
		QString path = QString("screenshot/screenshot_%1.png")
			.arg(QDateTime::currentMSecsSinceEpoch());  // 毫秒级时间戳
		pixmap.save(path);
	}
}

// 成员函数模板：将任意类型转换为字符串存储
template <typename T>
QByteArray QmlCppBridge::serializeMessage(const T& requestMsg) {
	const size_t msgSize = requestMsg.ByteSizeLong();
	QByteArray data;
	data.resize(static_cast<int>(msgSize));
	requestMsg.SerializeToArray(data.data(), data.size());
	return data;
}

