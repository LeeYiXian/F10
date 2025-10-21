#ifndef AXISCLASS_H1
#define AXISCLASS_H1
#include <QString>
#include <QObject>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFile>
#include <QDebug>
#include <vector>
#include <QCoreApplication>
#include <QMutex>
#include <map>
//#include <QDialog>
//#include <QTextEdit>
#include "LTDMC.h"
#include <QString>
#include <cstdint>
#include <vector>
#define xDISTANCE  1
#define xANGER  17.4533

enum MoveCommand {
    Positive, 
    Negative, 
    Stop,
    Gear
};
enum GearCommand {
    First, 
    Second, 
    Thrid
};
enum POSMODE
{
    RELATIVE_COORDINATE_MODE = 0,  // 相对坐标模式，明确赋值为0
    ABSOLUTE_COORDINATE_MODE = 1   // 绝对坐标模式，明确赋值为1
};
// 自定义结构体用于存储 minlimit 和 maxlimit
struct Limit {
    double minlimit;
    double maxlimit;
};

typedef struct _AxisParam
{
    // 构造函数，用于初始化结构体成员
    _AxisParam() :
        nConnectNum(0),
        wCard(0),
        wAxis(0),
        dEquiv(0.0),
        dStartSpeed(0.0),
        dSpeed(10.0),
        dChangePos(0.0),
        dAccTime(0.5),
        dChangeTime(0.0),
        dDecTime(0.5),
        dChangeSpeed(0.0),
        dStopSpeed(0.0),
        dSParaTime(0.0),
        dDistance(0.0),
        strIPAdress(""),
        strDeviceName(""),
        bEnableState(0),
        nOnPose(0),
        nOffPose(5),
        nErr(1),
        nMinlimit(0),
        nMaxlimit(1000),
        dCurentPos(0),
        doffsetPose(0)
    {
        // 初始化 m_Pose 数组
        for (int i = 0; i < 4; ++i)
        {
            nPose[i] = (i+1)*5;
        }
    }

    WORD    nConnectNum;
    WORD    wCard;
    WORD    wAxis;
    double  dEquiv;
    double  dStartSpeed;
    double  dSpeed;
    double  dChangePos;
    double  dAccTime;
    double  dChangeTime;
    double  dDecTime;
    double  dChangeSpeed;
    double  dStopSpeed;
    double  dSParaTime;
    double  dDistance;
    QString strIPAdress;
    QString strDeviceName;
    short   bEnableState;
    int     nUnitTrans;
    double     nOnPose;
    double     nOffPose;
    int     nPose[4];
    double     nErr;
    double  nMinlimit;
    double  nMaxlimit;
    double  dCurentPos;
    double  doffsetPose;
} AxisParam;
class AxisClass
{

public:
    AxisClass(WORD wConnectNum ,WORD wCard, WORD wAxis);
 private:
    AxisParam m_AxisParam;

     WORD    m_ConnectNum;
     WORD    m_wCard;
     WORD    m_wAxis;
     bool    bmovCMD;
     double  doffset;
     bool    hasFindZero;
     bool   synPosflag;
     std::vector<double> recentPositions;
 public:
    void setDeviceParams(AxisParam &pAxisParam);
    void getDeviceParams(AxisParam &sAxisParam);
    void setDeviceName(QString strName);
    void setDeviceSpeed(double speed);
    void setDevicemCard(WORD Card);
    void setposition_unit() ;
    void sethasFindZero(bool bFlag);
    bool gethasFindZero();
    QString getDeviceName();
    WORD getDevicemCard();
    WORD getDevicemmAxis();
    double getDeviceSpeed();
    double getDeviceEquiv();//获取脉冲当量
    int getDeviceOnOFFState(double realPose);//获取Axi7-8开关状态
    int getDevicegear(double realPose);//获取Axi9挡位状态

    bool enableAxis(bool state);
    void startMovDistance(double dDistance ,POSMODE posi_mode);//运动调用这个就可以了
    void startMoveRealTime(double dSpeed, MoveCommand moveCommand);
    void setMCLimit();//软限位
    short startSeteEuiv();//设置脉冲当量
    void homeAxis();//回零
    bool getMoveState();//获取运动状态
    short StopMove();//停止运动
    void clearErr();//清除错误
    void getLimitData(Limit &mLimit);
    int checkLimit(double &distance);//检查是否超过限位
    int checkRealPoseLimit();//检查是否超过限位
    short clearMultipleTurns();//清除多圈
    short getAbsolutePos(double & posVal);//绝对位置获取
    double getCurentPos();
    bool isMotorStopped(double threshold = 0.001);
    bool isZeroOver();
    // 新增函数，用于打印对象的所有参数
    void printAllParams() const;
    bool getHomeCMD();
    void setHomeCMD(bool cmd);
    void setsynPosflag(bool flag);
    bool getsynPosflag();
};

// 配置读取单例类
class ConfigReader {
public:
    static ConfigReader& getInstance() {
        static ConfigReader instance;
        return instance;
    }

    // 读取配置文件并设置AxisClass对象的函数
    bool readConfigAndSetAxisClasses(const QString& configFilePath);

    // 新建默认配置文件函数
    bool createDefaultConfigFile(const QString& filePath);
    QJsonObject getJsonObj();

private:
    ConfigReader() {}
    ~ConfigReader() {}
    ConfigReader(const ConfigReader&) = delete;
    ConfigReader& operator=(const ConfigReader&) = delete;
    QJsonObject rootObj;
};

const  QString deviceInfo[][2] = {
	{"1", "支撑平台方位运动"},
	{"2", "支撑平台俯仰运动"},
	{"3", "支撑平台垂直运动"},
	{"4", "大支撑升降平台"},
};

// 设置软件限位值
const std::vector<Limit> limits = {
	{-15, 15},
	{-90, 90},
	{0,300},
	{0, 2500}
};

// 设置脉冲当量微弧度 mm
const std::vector<double> dEquivs = {
    10922666.66,//1 轴 方位
    1747626.67,//2 轴 俯仰
    500000,//3 轴 升降
    80000//4194304//大升降
};

    // 设置轴状态机
const std::vector<QString> usAxisStateMachine ={
    "Not_Start",
    "Band_Start",
    "Ready_Start",
    "Moving" ,
    "Enable" ,
    "Stop",
    "ERR " 
};
    // 设置最大速度
const std::vector<double> MaxSpeed = {
    20,//1 轴 方位
    20,//2 轴 俯仰
    30,//3 轴 升降
    20// 4 轴 大升降
};
    // 设置适宜默认速度
const std::vector<double> DefaultSpeed = {
    5,//1 轴 方位
    5,//2 轴 俯仰
    10,//3 轴 升降
    5// 4 轴 大升降
};
#define OnPose 0
#define OffPose 5

// 定义轴目标类型枚举，避免字符串硬编码
enum class AxisTarget {
	X,          // platform.x
	Y,          // platform.y
	Z,          // platform.z
	Height,     // platform.height
	Unknown     // 未知目标
};

// 字符串转轴目标类型
AxisTarget stringToAxisTarget(const QString& target);
#endif // AXISCLASS_H1


