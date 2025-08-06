
#include "SerialPort.h"
#include <QSerialPortInfo>
#include <QFile>
#include <QMetaEnum>
/**
 * @brief �����๹�캯��
 * @param parent ������ָ��
 * @note ��ʼ�����ڶ�������Ĭ�ϲ�����115200�������źŲۣ���ˢ�¿��ö˿��б�
 */
SerialPort::SerialPort(QObject* parent)
    : QObject(parent), m_serial(new QSerialPort(this))
{
    // ���Ӵ������ݽ����ź�
    connect(m_serial, &QSerialPort::readyRead, this, &SerialPort::handleReadyRead);
    // ���Ӵ��ڴ����ź�
    connect(m_serial, &QSerialPort::errorOccurred, this, &SerialPort::handleError);
    // ��ʼ��ʱˢ�¿��ô����б�
    refreshPorts();
}

/**
 * @brief ����������ȷ���Ͽ���������
 */
SerialPort::~SerialPort()
{
    disconnectDevice();
}

void SerialPort::adjustFocus(float value)
{
	if (m_serial && m_serial->isOpen()) {
		//��ֵ����ȥ
	}
}

/**
 * @brief ��鴮���Ƿ�������
 * @return bool ����״̬
 */
bool SerialPort::isConnected() const
{
    return m_serial->isOpen();
}

/**
 * @brief ��ȡ��ǰϵͳ���ô����б�
 * @return QStringList ���ô��������б�
 */
QStringList SerialPort::availablePorts() const
{
	QStringList ports;

	// ����ϵͳ���п��ô���
	foreach(const QSerialPortInfo & info, QSerialPortInfo::availablePorts()) {
		ports << info.portName();
	}

	return ports;
}

/**
 * @brief ���Ӵ����豸
 * @note ���ô��ڲ��������Դ򿪣��ɹ�/ʧ�ܶ��ᷢ����Ӧ�ź�
 */
void SerialPort::connectDevice(const QString& portName, int baudRate)
{
    if (portName.isEmpty())
    {
        emit errorOccurred(QString::fromLocal8Bit("δѡ���豸"));  // ���ʹ�����Ϣ
        return;
    }

    QMutexLocker locker(&m_mutex);  // �̰߳�ȫ��
    if (m_serial->isOpen()) {
        emit errorOccurred(tr("Port already opened"));
        return;
    }

    // ���ô��ڲ���
    m_serial->setPortName(portName);          // ���ö˿���
    m_serial->setBaudRate(baudRate);          // ���ò�����
    m_serial->setDataBits(QSerialPort::Data8);  // 8λ����λ
    m_serial->setParity(QSerialPort::NoParity); // ��У��λ
    m_serial->setStopBits(QSerialPort::OneStop);// 1λֹͣλ
    m_serial->setFlowControl(QSerialPort::NoFlowControl); // ������

    // �����Զ�дģʽ�򿪴���
    if (m_serial->open(QIODevice::ReadWrite)) {
        emit connectionChanged(true);  // �������ӳɹ��ź�
    }
    else {
        emit errorOccurred(m_serial->errorString());  // ���ʹ�����Ϣ
    }
}

/**
 * @brief �Ͽ���������
 * @note �رմ��ڲ���������״̬�仯�ź�
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
 * @brief �������ݵ�����
 * @param data Ҫ���͵��ֽ�����
 * @note �̰߳�ȫ�����ݷ��ͷ���
 */
void SerialPort::sendData(const QByteArray& data)
{
    QMutexLocker locker(&m_mutex);
    if (m_serial->isOpen()) {
        m_serial->write(data);
    }
}

/**
 * @brief ���������ݽ��ղۺ���
 * @note �������ݵ���ʱ��������ȡ���п������ݲ�����dataReceived�ź�
 */
void SerialPort::handleReadyRead()
{
    //�����¶ȸı䴫ֵ
    QByteArray data = m_serial->readAll();
    if (!data.isEmpty()) {
        emit dataReceived(data);
    }
}

/**
 * @brief �����ڴ���ۺ���
 * @param error ��������ö��
 * @note �����ڷ�������ʱ���������ʹ�����Ϣ�ź�
 */
void SerialPort::handleError(QSerialPort::SerialPortError error)
{
	const QMetaEnum metaEnum = QMetaEnum::fromType<QSerialPort::SerialPortError>();
	emit errorOccurred(metaEnum.valueToKey(error));
}

/**
 * @brief ˢ�¿��ô����б�
 * @note ��⵱ǰ���ô��ڣ����б仯������б�����portsChanged�ź�
 */
void SerialPort::refreshPorts()
{
    emit portsChanged();
}
