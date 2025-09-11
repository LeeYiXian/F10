#pragma once
#include <QString>
#include <QSettings>
#include <QCoreApplication>

class ConfigManager
{
public:
	// ���캯������ָ�������ļ�·����Ĭ��ʹ�ó���Ŀ¼�µ� config.ini
	explicit ConfigManager(const QString& configPath = QCoreApplication::applicationDirPath() + "/config.ini")
		: settings(configPath, QSettings::IniFormat)
	{
	}

	// ��ȡ exe ·��
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
