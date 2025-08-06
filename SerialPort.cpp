
#include "SerialPort.h"
#include <QSerialPortInfo>
#include <QFile>
#include <QMetaEnum>
/**
 * @brief 串口类构造函数
 * @param parent 父对象指针
 * @note 初始化串口对象，设置默认波特率115200，连接信号槽，并刷新可用端口列表
 */
SerialPort::SerialPort(QObject* parent)
    : QObject(parent), m_serial(new QSerialPort(this))
{
    // 连接串口数据接收信号
    connect(m_serial, &QSerialPort::readyRead, this, &SerialPort::handleReadyRead);
    // 连接串口错误信号
    connect(m_serial, &QSerialPort::errorOccurred, this, &SerialPort::handleError);
    // 初始化时刷新可用串口列表
    refreshPorts();
}

/**
 * @brief 析构函数，确保断开串口连接
 */
SerialPort::~SerialPort()
{
    disconnectDevice();
}

void SerialPort::adjustFocus(float value)
{
	if (m_serial && m_serial->isOpen()) {
		//把值传下去
	}
}

/**
 * @brief 检查串口是否已连接
 * @return bool 连接状态
 */
bool SerialPort::isConnected() const
{
    return m_serial->isOpen();
}

/**
 * @brief 获取当前系统可用串口列表
 * @return QStringList 可用串口名称列表
 */
QStringList SerialPort::availablePorts() const
{
	QStringList ports;

	// 遍历系统所有可用串口
	foreach(const QSerialPortInfo & info, QSerialPortInfo::availablePorts()) {
		ports << info.portName();
	}

	return ports;
}

/**
 * @brief 连接串口设备
 * @note 配置串口参数并尝试打开，成功/失败都会发出相应信号
 */
void SerialPort::connectDevice(const QString& portName, int baudRate)
{
    if (portName.isEmpty())
    {
        emit errorOccurred(QString::fromLocal8Bit("未选择设备"));  // 发送错误信息
        return;
    }

    QMutexLocker locker(&m_mutex);  // 线程安全锁
    if (m_serial->isOpen()) {
        emit errorOccurred(tr("Port already opened"));
        return;
    }

    // 配置串口参数
    m_serial->setPortName(portName);          // 设置端口名
    m_serial->setBaudRate(baudRate);          // 设置波特率
    m_serial->setDataBits(QSerialPort::Data8);  // 8位数据位
    m_serial->setParity(QSerialPort::NoParity); // 无校验位
    m_serial->setStopBits(QSerialPort::OneStop);// 1位停止位
    m_serial->setFlowControl(QSerialPort::NoFlowControl); // 无流控

    // 尝试以读写模式打开串口
    if (m_serial->open(QIODevice::ReadWrite)) {
        emit connectionChanged(true);  // 发送连接成功信号
    }
    else {
        emit errorOccurred(m_serial->errorString());  // 发送错误信息
    }
}

/**
 * @brief 断开串口连接
 * @note 关闭串口并发送连接状态变化信号
 */
void SerialPort::disconnectDevice()
{
    QMutexLocker locker(&m_mutex);
    if (m_serial->isOpen()) {
        m_serial->close();
        emit connectionChanged(false);
    }
}

/**
 * @brief 发送数据到串口
 * @param data 要发送的字节数组
 * @note 线程安全的数据发送方法
 */
void SerialPort::sendData(const QByteArray& data)
{
    QMutexLocker locker(&m_mutex);
    if (m_serial->isOpen()) {
        m_serial->write(data);
    }
}

/**
 * @brief 处理串口数据接收槽函数
 * @note 当有数据到达时触发，读取所有可用数据并发出dataReceived信号
 */
void SerialPort::handleReadyRead()
{
    //处理温度改变传值
    QByteArray data = m_serial->readAll();
    if (!data.isEmpty()) {
        emit dataReceived(data);
    }
}

/**
 * @brief 处理串口错误槽函数
 * @param error 错误类型枚举
 * @note 当串口发生错误时触发，发送错误信息信号
 */
void SerialPort::handleError(QSerialPort::SerialPortError error)
{
	const QMetaEnum metaEnum = QMetaEnum::fromType<QSerialPort::SerialPortError>();
	emit errorOccurred(metaEnum.valueToKey(error));
}

/**
 * @brief 刷新可用串口列表
 * @note 检测当前可用串口，如有变化则更新列表并发送portsChanged信号
 */
void SerialPort::refreshPorts()
{
    emit portsChanged();
}
