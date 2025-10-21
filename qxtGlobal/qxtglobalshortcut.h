#ifndef QXTGLOBALSHORTCUT_H
#define QXTGLOBALSHORTCUT_H

#include "qxtglobal.h"
#include <QObject>
#include <QKeySequence>

class QxtGlobalShortcutPrivate;

class QXT_GUI_EXPORT QxtGlobalShortcut : public QObject
{
	Q_OBJECT
		QXT_DECLARE_PRIVATE(QxtGlobalShortcut)
		Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled)
		Q_PROPERTY(QKeySequence shortcut READ shortcut WRITE setShortcut)

public:
	explicit QxtGlobalShortcut(QObject* parent = nullptr);
	explicit QxtGlobalShortcut(const QKeySequence& shortcut, QObject* parent = nullptr);
	virtual ~QxtGlobalShortcut();

	QKeySequence shortcut() const;
	bool setShortcut(const QKeySequence& shortcut);

	bool isEnabled() const;

public Q_SLOTS:
	void setEnabled(bool enabled = true);
	void setDisabled(bool disabled = true);

Q_SIGNALS:
	void activated();
};
#endif // QXTGLOBALSHORTCUT_H
