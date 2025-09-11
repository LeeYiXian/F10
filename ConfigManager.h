#pragma once
#include <QString>
#include <QSettings>
#include <QCoreApplication>

class ConfigManager
{
public:
	// 构造函数，可指定配置文件路径，默认使用程序目录下的 config.ini
	explicit ConfigManager(const QString& configPath = QCoreApplication::applicationDirPath() + "/config.ini")
		: settings(configPath, QSettings::IniFormat)
	{
	}

	// 获取 exe 路径
	QString getProgramPath(const QString& key) const
	{
		return settings.value("ExternalPrograms/" + key).toString();
	}

	QString getCOM(const QString& key) const
	{
		return settings.value("ShakingTableCOM/" + key).toString();
	}

private:
	QSettings settings;
};
