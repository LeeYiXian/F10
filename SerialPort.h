
#ifndef SERIALCONNECTION_H
#define SERIALCONNECTION_H

#include <QObject>
#include <QSerialPort>
#include <QStringList>
#include <QMutex>

/**
 * @brief 串口通信类，封装了Qt的串口通信功能
 *
 * 该类提供了串口连接、断开、数据收发等基本功能，
 * 并通过Qt信号槽机制实现异步通信
 */
class SerialPort : public QObject
{
    Q_OBJECT

        // 属性声明
        Q_PROPERTY(bool connected READ isConnected NOTIFY connectionChanged)       // 连接状态属性
        Q_PROPERTY(QStringList availablePorts READ availablePorts NOTIFY portsChanged) // 可用端口列表属性

public:
    /**
     * @brief 构造函数
     * @param parent 父对象指针
     */
    explicit SerialPort(QObject* parent = nullptr);

    /**
     * @brief 析构函数
     */
    ~SerialPort();

    /**
     * @brief 获取当前连接状态
     * @return true表示已连接，false表示未连接
     */
    bool isConnected() const;

    /**
     * @brief 获取可用串口列表
     * @return 可用串口名称列表
     */
    QStringList availablePorts() const;

public slots:
    /**
     * @brief 连接串口设备
     */
    Q_INVOKABLE void connectDevice(const QString& portName, int baudRate);

    /**
     * @brief 断开串口设备
     */
    Q_INVOKABLE void disconnectDevice();

    /**
     * @brief 发送数据
     * @param data 要发送的数据
     */
    void sendData(const QByteArray& data);

    /**
     * @brief 刷新可用串口列表
     */
    void refreshPorts();

signals:
    /**
     * @brief 连接状态改变信号
     * @param connected 新的连接状态
     */
    void connectionChanged(bool connected);

    /**
     * @brief 可用端口列表改变信号
     */
    void portsChanged();

    /**
     * @brief 波特率改变信号
     */
    void log(const QString& msg);

    /**
     * @brief 接收到数据信号
     * @param data 接收到的数据
     */
    void dataReceived(const QByteArray& data);

    /**
     * @brief 错误发生信号
     * @param error 错误描述
     */
    void errorOccurred(const QString& error);

    /**
     * @brief 错误发生信号
     * @param error 错误描述
     */
    void progressChanged(int value);

private slots:
    /**
     * @brief 处理数据接收
     */
    void handleReadyRead();

    /**
     * @brief 处理串口错误
     * @param error 错误类型
     */
    void handleError(QSerialPort::SerialPortError error);

private:
    QSerialPort* m_serial;        // 串口对象指针
    QMutex m_mutex;              // 互斥锁，用于线程安全
    QStringList m_availablePorts; // 可用串口列表
};

#endif // SERIALCONNECTION_H
