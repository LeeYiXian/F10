#ifndef LOGGERS_H
#define LOGGERS_H
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QDateTime>
#include <QCoreApplication>
#include <QProcess>
#include <cstdarg>
#include <QThread>
#include <QDir>

class Logger
{
public:
    static Logger& getInstance()
    {
        static Logger instance;
        return instance;
    }

    void log(const QString &level, const QString &fileName, int lineNumber, const char *format, ...)
    {
        va_list args;
        va_start(args, format);
        QString message = QString::vasprintf(format, args);
        va_end(args);

        QString formattedMessage = formatMessage(level, message, fileName, lineNumber);
        checkAndRotateLogFile();
        QTextStream out(&m_logFile);
        out << formattedMessage << "\n";
    }

private:
    Logger() : m_logFile(getLogFileName())
    {
        m_logFile.open(QIODevice::Append | QIODevice::Text);
    }

    ~Logger()
    {
        if (m_logFile.isOpen())
            m_logFile.close();
    }

    QString getLogFileName()
    {
        // 指定日志文件目录
        QString logDirectory = "log/";

        //检查目录是否存在，如果不存在则创建
        QDir dir(logDirectory);
        if (!dir.exists()) {
            if (!dir.mkpath(".")) {
                qCritical() << "Failed to create log directory:" << logDirectory;
            }
            //  newFileName = logDirectory+ newFileName;
        }
        QString processId = QString::number(QCoreApplication::applicationPid());
        QString dateTime = QDateTime::currentDateTime().toString("yyyy-MM-dd_HH-mm-ss");
        return logDirectory.append(QString("SMSS_%1-%2.log").arg(processId).arg(dateTime));
    }

    void checkAndRotateLogFile()
    {
        if (!m_logFile.isOpen())
        {
            if (!m_logFile.open(QIODevice::Append | QIODevice::Text))
            {
                qCritical() << "Failed to open log file:" << m_logFile.errorString();
                return;
            }
        }

        if (m_logFile.size() > 100 * 1024 * 1024) // 100MB
        {
            m_logFile.close();
            QString newFileName = getLogFileName();
            m_logFile.setFileName(newFileName);
            if (!m_logFile.open(QIODevice::Append | QIODevice::Text))
            {
                qCritical() << "Failed to open new log file:" << m_logFile.errorString();
            }
        }
    }

    QString formatMessage(const QString &level, const QString &message, const QString &fileName, int lineNumber)
    {
        QString threadId = QString::number(reinterpret_cast<quint64>(QThread::currentThreadId()));
        return QString("%1: %2 %3 (File: %4, Line: %5)[pid:%6,tid:%7]")
                .arg(QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss"))
                .arg(level)
                .arg(message)
                .arg(fileName)
                .arg(lineNumber)
                .arg(QCoreApplication::applicationPid())
                .arg(threadId);

    }

private:
    QFile m_logFile;

    Logger(const Logger&) = delete;
    Logger& operator=(const Logger&) = delete;
};

#define LX_LOG_INFO(format, ...) Logger::getInstance().log("[INFO]", __FILE__, __LINE__, format, ##__VA_ARGS__)
#define LX_LOG_ERR(format, ...) Logger::getInstance().log("[ERROR]", __FILE__, __LINE__, format, ##__VA_ARGS__)

enum ThreadState {
    DEFAULT = -1,
    START = 0,
    STOP = 1,
    UNKNOW = 2
};
#endif // LOGGERS_H
