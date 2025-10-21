#ifndef QXTGLOBAL_H
#define QXTGLOBAL_H

#include <QtGlobal>

#define QXT_VERSION 0x000700
#define QXT_VERSION_STR "0.7.0"

//--------------------------export macros------------------------------
// 直接内嵌项目使用，不导出 DLL
#define QXT_DLLEXPORT
#define QXT_CORE_EXPORT
#define QXT_GUI_EXPORT
#define QXT_NETWORK_EXPORT
#define QXT_SQL_EXPORT
#define QXT_WEB_EXPORT
#define QXT_BERKELEY_EXPORT
#define QXT_ZEROCONF_EXPORT

QXT_CORE_EXPORT const char* qxtVersion();

#ifndef QT_BEGIN_NAMESPACE
#define QT_BEGIN_NAMESPACE
#endif

#ifndef QT_END_NAMESPACE
#define QT_END_NAMESPACE
#endif

#ifndef QT_FORWARD_DECLARE_CLASS
#define QT_FORWARD_DECLARE_CLASS(Class) class Class;
#endif

// QxtPrivate 宏和模板
#define QXT_DECLARE_PRIVATE(PUB) friend class PUB##Private; QxtPrivateInterface<PUB, PUB##Private> qxt_d;
#define QXT_DECLARE_PUBLIC(PUB) friend class PUB;
#define QXT_INIT_PRIVATE(PUB) qxt_d.setPublic(this);
#define QXT_D(PUB) PUB##Private& d = qxt_d()
#define QXT_P(PUB) PUB& p = qxt_p()

template <typename PUB>
class QxtPrivate
{
public:
	virtual ~QxtPrivate() {}
	inline void QXT_setPublic(PUB* pub)
	{
		qxt_p_ptr = pub;
	}

protected:
	inline PUB& qxt_p() { return *qxt_p_ptr; }
	inline const PUB& qxt_p() const { return *qxt_p_ptr; }
	inline PUB* qxt_ptr() { return qxt_p_ptr; }
	inline const PUB* qxt_ptr() const { return qxt_p_ptr; }

private:
	PUB* qxt_p_ptr = nullptr;
};

template <typename PUB, typename PVT>
class QxtPrivateInterface
{
	friend class QxtPrivate<PUB>;
public:
	QxtPrivateInterface()
	{
		pvt = new PVT;
	}
	~QxtPrivateInterface()
	{
		delete pvt;
	}

	inline void setPublic(PUB* pub)
	{
		pvt->QXT_setPublic(pub);
	}
	inline PVT& operator()() { return *static_cast<PVT*>(pvt); }
	inline const PVT& operator()() const { return *static_cast<PVT*>(pvt); }
	inline PVT* operator->() { return static_cast<PVT*>(pvt); }
	inline const PVT* operator->() const { return static_cast<PVT*>(pvt); }

private:
	QxtPrivateInterface(const QxtPrivateInterface&) {}
	QxtPrivateInterface& operator=(const QxtPrivateInterface&) {}
	QxtPrivate<PUB>* pvt;
};

#endif // QXTGLOBAL_H
