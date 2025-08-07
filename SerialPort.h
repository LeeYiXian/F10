
#ifndef SERIALCONNECTION_H
#define SERIALCONNECTION_H

#include <QObject>
#include <QSerialPort>
#include <QStringList>
#include <QMutex>

/**
 * @brief ����ͨ���࣬��װ��Qt�Ĵ���ͨ�Ź���
 *
 * �����ṩ�˴������ӡ��Ͽ��������շ��Ȼ������ܣ�
 * ��ͨ��Qt�źŲۻ���ʵ���첽ͨ��
 */
class SerialPort : public QObject
{
    Q_OBJECT

        // ��������
        Q_PROPERTY(bool connected READ isConnected NOTIFY connectionChanged)       // ����״̬����
        Q_PROPERTY(QStringList availablePorts READ availablePorts NOTIFY portsChanged) // ���ö˿��б�����

public:
    /**
     * @brief ���캯��
     * @param parent ������ָ��
     */
    explicit SerialPort(QObject* parent = nullptr);

    /**
     * @brief ��������
     */
    ~SerialPort();

    /**
     * @brief ��ȡ��ǰ����״̬
     * @return true��ʾ�����ӣ�false��ʾδ����
     */
    bool isConnected() const;

    /**
     * @brief ��ȡ���ô����б�
     * @return ���ô��������б�
     */
    QStringList availablePorts() const;

public slots:
    /**
     * @brief ���Ӵ����豸
     */
    Q_INVOKABLE void connectDevice(const QString& portName, int baudRate);

    /**
     * @brief �Ͽ������豸
     */
    Q_INVOKABLE void disconnectDevice();

    /**
     * @brief ��������
     * @param data Ҫ���͵�����
     */
    void sendData(const QByteArray& data);

    /**
     * @brief ˢ�¿��ô����б�
     */
    void refreshPorts();

signals:
    /**
     * @brief ����״̬�ı��ź�
     * @param connected �µ�����״̬
     */
    void connectionChanged(bool connected);

    /**
     * @brief ���ö˿��б�ı��ź�
     */
    void portsChanged();

    /**
     * @brief �����ʸı��ź�
     */
    void log(const QString& msg);

    /**
     * @brief ���յ������ź�
     * @param data ���յ�������
     */
    void dataReceived(const QByteArray& data);

    /**
     * @brief �������ź�
     * @param error ��������
     */
    void errorOccurred(const QString& error);

    /**
     * @brief �������ź�
     * @param error ��������
     */
    void progressChanged(int value);

private slots:
    /**
     * @brief �������ݽ���
     */
    void handleReadyRead();

    /**
     * @brief �����ڴ���
     * @param error ��������
     */
    void handleError(QSerialPort::SerialPortError error);

private:
    QSerialPort* m_serial;        // ���ڶ���ָ��
    QMutex m_mutex;              // �������������̰߳�ȫ
    QStringList m_availablePorts; // ���ô����б�
};

#endif // SERIALCONNECTION_H
