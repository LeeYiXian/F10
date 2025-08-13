#include "axisclass.h"
#include "Loggers.h"

AxisClass::AxisClass(WORD wConnectNum ,WORD wCard, WORD wAxis):
m_ConnectNum(wConnectNum),
m_wCard(wCard),
m_wAxis(wAxis)
{
    m_AxisParam.nConnectNum = wConnectNum;
    m_AxisParam.wCard = wCard;
    m_AxisParam.wAxis = wAxis;
    bmovCMD = false;
    doffset = 0;
    hasFindZero = false;
    synPosflag = false;

}
void AxisClass::setDeviceParams(AxisParam &pAxisParam)
{
    m_AxisParam = pAxisParam;
}
void AxisClass::getDeviceParams(AxisParam &pAxisParam)
{
    pAxisParam = m_AxisParam;
}

void AxisClass::setDeviceName(QString strName)
{
    m_AxisParam.strDeviceName = strName;
}

void AxisClass::setDeviceSpeed(double speed)
{
    m_AxisParam.dSpeed = speed;
}

void AxisClass::setDevicemCard(WORD Card)
{
    m_wCard = Card;
    m_AxisParam.wCard = Card;
}

void AxisClass::setposition_unit()
{
    double posVal =0;
    getAbsolutePos(posVal);//绝对位置获取dmc_set_position_unit
    dmc_set_position_unit(m_AxisParam.wCard, m_AxisParam.wAxis,posVal );
}

void AxisClass::sethasFindZero(bool bFlag)
{
    hasFindZero = bFlag;
}

bool AxisClass::gethasFindZero()
{
    return hasFindZero;
}


double AxisClass::getDeviceEquiv()
{
    return m_AxisParam.dEquiv ;
}

int AxisClass::getDeviceOnOFFState(double realPose)
{

    int ret =-1;
    if(abs(realPose -  m_AxisParam.nOnPose) <= m_AxisParam.nErr)
    {
        ret =  1;
    }
    else if(abs(realPose -  m_AxisParam.nOffPose) <= m_AxisParam.nErr)
    {
         ret = 2;
    }
    // LX_LOG_INFO(" realPose:%f nOnPose[%f] nOffPose[%f] nErr[%f] ret[%d]" ,
    //             realPose ,  m_AxisParam.nOnPose ,m_AxisParam.nOffPose,m_AxisParam.nErr ,ret);
    return ret;
}

int AxisClass::getDevicegear(double realPose)
{
    int ret = -1;
    for(int i = 0 ;i < 4 ;i++)
    {
        if(abs(realPose - m_AxisParam.nPose[i]) < m_AxisParam.nErr)
        {
            ret = i;
        }
    }
    return ret;
}

WORD AxisClass::getDevicemCard()
{
    return m_AxisParam.wCard;
}
WORD AxisClass::getDevicemmAxis()
{
    return m_AxisParam.wAxis;
}
double AxisClass::getDeviceSpeed()
{
    return m_AxisParam.dSpeed;
}
QString AxisClass::getDeviceName()
{
    return m_AxisParam.strDeviceName;
}
//nmc_set_axis_enable和nmc_set_axis_disable返回值不能作为实际使能状态，始终返回0 失败是错误码
bool AxisClass::enableAxis(bool state)
{
     LX_LOG_INFO("m_wCard=%d m_wAxis=%d state[%d] bEnableState=%d begin", m_wCard, m_wAxis, state,m_AxisParam.bEnableState);
    //先清理轴错误 再使能
    if(state)
    {
        if(nmc_set_axis_enable(m_wCard, m_wAxis))return false;
        m_AxisParam.bEnableState = true;
    }
    else
    {
        if(nmc_set_axis_disable(m_wCard, m_wAxis))return false;
        m_AxisParam.bEnableState = false;
    }
    return true;
}

void AxisClass::startMovDistance(double dDistance ,POSMODE posi_mode)
{
    LX_LOG_INFO("Function startMovDistance called with dDistance = %f, posi_mode = %d", dDistance, posi_mode);
    if(posi_mode == ABSOLUTE_COORDINATE_MODE) checkLimit(dDistance);
     m_AxisParam.dDistance = dDistance ;
    if (dmc_check_done( m_wCard,m_wAxis ) == 0) //已经在运动中
    {
        LX_LOG_INFO("m_wAxis=%d is moving", m_wAxis);
        return;
    }

    //单轴运动速度曲线设置
    short result = dmc_set_profile_unit(m_wCard, m_wAxis, m_AxisParam.dStartSpeed,
                                        m_AxisParam.dSpeed, m_AxisParam.dAccTime,
                                        m_AxisParam.dDecTime, m_AxisParam.dStopSpeed);
    LX_LOG_INFO("[dmc_set_profile_unit] card = %hu, axis = %hu, startSpeed = %f, speed = %f, accTime = %f, decTime = %f, stopSpeed = %f returned %d",
                m_wCard, m_wAxis, m_AxisParam.dStartSpeed, m_AxisParam.dSpeed,
                m_AxisParam.dAccTime, m_AxisParam.dDecTime, m_AxisParam.dStopSpeed ,result);
    //设定S段时间
    result = dmc_set_s_profile(m_wCard,m_wAxis,0,m_AxisParam.dSParaTime);
    LX_LOG_INFO("[dmc_set_s_profile] axis = %hu, sParaTime = %f ,returned %d", m_wAxis,m_AxisParam.dSParaTime ,result);
    //点动(位置模式)
    result =  dmc_pmove_unit(m_wCard, m_wAxis, m_AxisParam.dDistance, posi_mode);
    LX_LOG_INFO("[dmc_pmove_unit] axis = %hu, m_dDistance = %f ,posi_mode =%d ,returned %d",
                m_wAxis,m_AxisParam.dDistance ,posi_mode ,result);
    //启动-》停止 对应调用接口
    //dmc_set_profile_unit(8,1,10000000,0.1,0.1,0)=0->dmc_set_s_profile(8,1,0,0.05)=0->dmc_pmove_unit(8,1,10000000,0)=0->dmc_stop(8,1,0)=0
    //箭头调用函数,按钮点击运动，松开停止
    //dmc_set_profile_unit(8,1,10000000,0.1,0.1,0)=0->dmc_set_s_profile(8,1,0,0.05)=0->dmc_vmove(8,1,0)=0->dmc_stop(8,1,0)=0
}
void AxisClass::startMoveRealTime(double dSpeed, MoveCommand moveCommand)
{
    if (moveCommand == MoveCommand::Stop)
    {
        if(dmc_stop(m_wCard, m_wAxis, 0))
        {
            LX_LOG_INFO("dmc_stop failed");
        }
        return;
    }
    if (dmc_check_done(m_wCard, m_wAxis) == 0) // 已经在运动中
    {
        LX_LOG_INFO("m_wAxis=%d is moving", m_wAxis);
        return;
    }
    if (dmc_set_profile_unit(m_wCard, m_wAxis, m_AxisParam.dStartSpeed,
                             dSpeed, m_AxisParam.dAccTime,
                             m_AxisParam.dDecTime, m_AxisParam.dStopSpeed) != 0)
    {
        LX_LOG_INFO("dmc_set_profile_unit failed");
    }
    LX_LOG_INFO("[dmc_set_profile_unit] card = %hu, axis = %hu, startSpeed = %f, speed = %f, accTime = %f, decTime = %f, stopSpeed = %f",
                m_wCard, m_wAxis, m_AxisParam.dStartSpeed, dSpeed,
                m_AxisParam.dAccTime, m_AxisParam.dDecTime, m_AxisParam.dStopSpeed);
    if(dmc_set_s_profile(m_wCard, m_wAxis, 0, m_AxisParam.dSParaTime) != 0)
    {
        LX_LOG_INFO("dmc_set_s_profile failed");
    }
    if (moveCommand == MoveCommand::Positive)
    {
        if(dmc_vmove(m_wCard, m_wAxis, 0))
        {
            LX_LOG_INFO("dmc_vmove Positive failed");
        }
    }
    else if (moveCommand == MoveCommand::Negative)
    {
        if(dmc_vmove(m_wCard, m_wAxis, 1))
        {
            LX_LOG_INFO("dmc_vmove MoveNegative failed");
        }
    }
}
void AxisClass::setMCLimit()
{
     LX_LOG_INFO("dmc_get_softlimit_unit m_wCard:%d ,m_wAxis:%d ", m_wCard ,m_wAxis);
    WORD enable = 0;
    WORD source_sel = 0;
    WORD SL_actIOn = 0;
    double N_limit = 0;
    double P_limit  = 0;
    QString resultMessage;
    short getResult = dmc_get_softlimit_unit(m_wCard, m_wAxis, &enable, &source_sel, &SL_actIOn, &N_limit, &P_limit);
    if (getResult == 0)
    {
         resultMessage = QString("软限位读取成功使能状态: %1 计数器选择: %2  限位停止方式: %3 负限位位置: %4 正限位位置: %5")
                              .arg(enable).arg(source_sel).arg(SL_actIOn).arg(N_limit).arg(P_limit);
         LX_LOG_INFO("dmc_get_softlimit_unit %s" , resultMessage.toUtf8().constData());
    }
    else
    {
        resultMessage = QString("单轴软限位读取失败，错误代码: %1\n").arg(getResult);
            LX_LOG_INFO("dmc_get_softlimit_unit resultMessage:%s ",resultMessage.toUtf8().constData());
        return;
    }
    //设置
    enable = true;
    source_sel = 1;//计数器选择， 0： 指令位置计数器， 1： 编码器计数器
    SL_actIOn = 0;// 限位停止方式， 0： 立即停止 1： 减速停止
    N_limit = m_AxisParam.nMinlimit;//负限位位置， 单位： unit
    P_limit = m_AxisParam.nMaxlimit;//正限位位置， 单位： unit
    short setResult = dmc_set_softlimit_unit(m_wCard, m_wAxis, enable, source_sel, SL_actIOn, N_limit, P_limit);
    if (setResult == 0)
    {
         resultMessage = QString("单轴软限位设置成功。使能状态: %1 计数器选择: %2  限位停止方式: %3 负限位位置: %4 正限位位置: %5")
                        .arg(enable).arg(source_sel).arg(SL_actIOn).arg(N_limit).arg(P_limit);
         LX_LOG_INFO("dmc_set_softlimit_unit resultMessage:%s ",resultMessage.toUtf8().constData());
    } else
    {
        resultMessage = QString("单轴软限位设置失败，错误代码: %1\n").arg(setResult);
        resultMessage += QString("使能状态: %1 计数器选择: %2  限位停止方式: %3 负限位位置: %4 正限位位置: %5")
                            .arg(enable).arg(source_sel).arg(SL_actIOn).arg(N_limit).arg(P_limit);
    }

    LX_LOG_INFO("dmc_get_softlimit_unit resultMessage:%s ",resultMessage.toUtf8().constData());

}

short AxisClass::startSeteEuiv()
{
    short ret = dmc_set_equiv(m_wCard,m_wAxis, m_AxisParam.dEquiv);
     LX_LOG_INFO("startSeteEuiv Name: %d, m_wAxis: %d,m_dEquiv:%f ret:%d",
                getDeviceName().toStdString().c_str(), m_wAxis ,m_AxisParam.dEquiv , ret);
    return ret;
}


void AxisClass::homeAxis()
{
    if(m_wAxis >= 0 && m_wAxis < 7 )
    {
        startMovDistance(0 ,ABSOLUTE_COORDINATE_MODE);
        LX_LOG_INFO("[homeAxis] pAxisObj[%s] home m_wAxis[%f] Minlimit:[%f]",
                    getDeviceName().toUtf8().constData(), m_wAxis ,m_AxisParam.nMinlimit);

    }
    else if(m_wAxis  == 7 )
    {
        ushort Mymode,statemachine;
        statemachine=0;
        Mymode=17; //回零方式为
        int ret = 0;
        nmc_get_axis_state_machine(m_wCard, m_wAxis, &statemachine);//获取轴状态机
        LX_LOG_INFO("m_wAxis[%d] statemachine=%d",m_wAxis ,statemachine);
        if(statemachine == 4) //监控轴状态机的值， 该值等于 4 表示轴状态机处于准备好状态
        {
            nmc_set_home_profile(m_wCard,m_wAxis, Mymode,2, 4, 0.1, 0.1, 0);
            //设置回原点模式 ,设置 0 号轴梯形速度曲线参数
            ret = nmc_home_move(m_wCard,m_wAxis);//执行回原点运动
            LX_LOG_INFO("[homeAxis]  Axis[%s] home statemachine[%d] 执行回原点运动 ret:[%d]", getDeviceName().toUtf8().constData(), statemachine ,ret);
            setHomeCMD(true);
            doffset = 0;
        }
        else
        {
            LX_LOG_INFO("[homeAxis]  Axis[%s] home statemachine[%d] %s ret:[%d]",
                        getDeviceName().toUtf8().constData(), statemachine ,usAxisStateMachine[statemachine].toStdString().c_str(),ret);
        }
    }
    else//8 和9
    {
        ushort Mymode,statemachine;
        statemachine=0;
        Mymode=22; //回零方式为
        int ret = 0;
        nmc_get_axis_state_machine(m_wCard, m_wAxis, &statemachine);//获取轴状态机
        LX_LOG_INFO("m_wAxis[%d] statemachine=%d",m_wAxis ,statemachine);
        if(statemachine == 4) //监控轴状态机的值， 该值等于 4 表示轴状态机处于准备好状态
        {
            nmc_set_home_profile(m_wCard,m_wAxis, Mymode,2, 4, 0.1, 0.1, 0);
            //设置回原点模式 ,设置 0 号轴梯形速度曲线参数
            ret = nmc_home_move(m_wCard,m_wAxis);//执行回原点运动
            LX_LOG_INFO("[homeAxis]  Axis[%s] home statemachine[%d] 执行回原点运动 ret:[%d]", getDeviceName().toUtf8().constData(), statemachine ,ret);
            setHomeCMD(true);
            doffset = 0;
        }
        else
        {
            LX_LOG_INFO("[homeAxis]  Axis[%s] home statemachine[%d] %s ret:[%d]",
                        getDeviceName().toUtf8().constData(), statemachine ,usAxisStateMachine[statemachine].toStdString().c_str(),ret);
        }
    }


}

bool AxisClass::getMoveState()
{
    short ret = dmc_check_done(m_wCard, m_wAxis);
    LX_LOG_INFO("dmc_check_done Name: %d, m_wAxis: %d, ret:%d",
                getDeviceName().toStdString().c_str(), m_wAxis ,ret);
    return ret == 0;
}

short AxisClass::StopMove()
{
    setHomeCMD(false);
     short ret = dmc_stop(m_wCard,m_wAxis,0);
    LX_LOG_INFO("dmc_stop Name: %d, m_wAxis: %d, ret:%d",
                getDeviceName().toStdString().c_str(), m_wAxis ,ret);
     return ret;
}

void AxisClass::clearErr()
{
    // WORD Errcode = 0;
    //  short ret =  nmc_get_card_errcode(m_wCard,&Errcode);

    // // 清除控制卡错误码
    // ret = nmc_clear_card_errcode(m_wCard);
    // LX_LOG_INFO("nmc_clear_card_errcode Name: %d, m_wCard: %d,Errcode:%d ret:%d",
    //             getDeviceName().toStdString().c_str(), m_wCard ,Errcode ,ret);
    // // 清除总线轴错误码
    // ret = nmc_get_axis_errcode(m_wCard ,m_wAxis ,&Errcode);

   short  ret = nmc_clear_axis_errcode(m_wCard, m_wAxis);
    LX_LOG_INFO("nmc_clear_axis_errcode Name: %d,m_wCard:%d, m_wAxis: %d, ret:%d",
                getDeviceName().toStdString().c_str(),m_wCard, m_wAxis ,ret);

    WORD PortNum = 2 ;
    WORD NodeNum = 1001 +m_wAxis;
    WORD Index = 0x4106;
    WORD SubIndex =  0;
    WORD ValLength =  32;
    long Value = 1;
 //    ret  = nmc_get_node_od( m_wCard , PortNum , NodeNum , Index , SubIndex , ValLength , &Value ) ;
 //    LX_LOG_INFO("nmc_get_node_od( m_wCard:%d,PortNum:%d , NodeNum:%d , Index:%d , SubIndex:%d , ValLength:%d , Value:%d )  ret:%d",
 //                m_wCard ,PortNum , NodeNum , Index , SubIndex ,ValLength ,Value, ret);
 //    ret  = nmc_set_node_od( m_wCard , PortNum , NodeNum , Index , SubIndex , ValLength , 1 ) ;
    // Value = 1;
 //    LX_LOG_INFO("nmc_set_node_od( m_wCard:%d,PortNum:%d , NodeNum:%d , Index:%d , SubIndex:%d , ValLength:%d , Value:%d )  ret:%d",
 //                m_wCard ,PortNum , NodeNum , Index , SubIndex ,ValLength,Value , ret);

}

void AxisClass::getLimitData(Limit &mLimit)
{
    mLimit.maxlimit = m_AxisParam.nMaxlimit;
    mLimit.minlimit = m_AxisParam.nMinlimit;
}

int AxisClass::checkLimit(double &distance)
{

    int ret = 0;
   if (distance < m_AxisParam.nMinlimit)
    {

       LX_LOG_INFO("AxixName[%s] distance[%d] < m_AxisParam.nMinlimit , force nMinlimit",
                   m_AxisParam.strDeviceName.toStdString().c_str(),
                   distance, m_AxisParam.nMinlimit);
       distance = m_AxisParam.nMinlimit;
       ret = 1;
    }
   else if (distance > m_AxisParam.nMaxlimit)
   {

        LX_LOG_INFO("AxixName[%s] distance[%d] > m_AxisParam.nMaxlimit , force nMaxlimit",
                    m_AxisParam.strDeviceName.toStdString().c_str(),
                    distance, m_AxisParam.nMaxlimit);
        distance = m_AxisParam.nMaxlimit;
       ret = 2;
   }
    return ret;

}

int AxisClass::checkRealPoseLimit()
{

    int ret = 0;
    double distance = getCurentPos();
    if (distance < m_AxisParam.nMinlimit || distance > m_AxisParam.nMaxlimit)
    {
        StopMove();
        LX_LOG_INFO("AxixName[%s] distance[%f] < nMinlimit or > nMaxlimit, force Stop",
                    m_AxisParam.strDeviceName.toStdString().c_str(),distance);
    }
    return ret;
}

short AxisClass::clearMultipleTurns()
{
    WORD PortNum = 2 ;
    WORD NodeNum = 1001 +m_wAxis;
    WORD Index = 0x4106;//清除多圈
    WORD SubIndex =  0;
    WORD ValLength =  32;
    long Value = 1;
    short ret = 0;
    ret  = nmc_get_node_od( m_wCard , PortNum , NodeNum , Index , SubIndex , ValLength , &Value ) ;
    LX_LOG_INFO("nmc_set_node_od( m_wCard:%d,PortNum:%d , NodeNum:%d , Index:%d , SubIndex:%d , ValLength:%d , Value:%d )  ret:%d",
                m_wCard ,PortNum , NodeNum , Index , SubIndex ,ValLength ,Value, ret);
    return ret;
}

short AxisClass::getAbsolutePos(double &posVal)
{
    WORD PortNum = 2 ;
    WORD NodeNum = 1001 +m_wAxis;
    WORD Index = 0x6064;//获取绝对位置
    WORD SubIndex =  0;
    WORD ValLength =  32;
    long  Value = 0;
    short ret = 0;
    ret  = nmc_get_node_od( m_wCard , PortNum , NodeNum , Index , SubIndex , ValLength , &Value );
    posVal = static_cast<double>(Value/ m_AxisParam.dEquiv);
    m_AxisParam.dCurentPos = posVal - m_AxisParam.doffsetPose;

    //判斷尋零
    // if(bmovCMD)
    // {
    //     if(isMotorStopped())
    //     {
    //         bmovCMD = false;
    //         doffset = m_AxisParam.dCurentPos;
    //         LX_LOG_INFO("%s Find zero  Over offset:%f", getDeviceName().toStdString().c_str(), m_AxisParam.dCurentPos);
    //     }
    //     LX_LOG_INFO("%s Finding zero pose now : %f", getDeviceName().toStdString().c_str(), m_AxisParam.dCurentPos);
    // }

   // isMotorStopped();
    // LX_LOG_INFO("%s 获取绝对位置：m_wCard:%d,PortNum:%d , NodeNum:%d , Index:%d , SubIndex:%d , ValLength:%d , Value:%d，posVal:%f  ret:%d",
    //            getDeviceName().toStdString().c_str(), m_wCard ,PortNum , NodeNum , Index , SubIndex ,ValLength ,Value, posVal, ret);
    return ret;
}

double AxisClass::getCurentPos()
{
   return m_AxisParam.dCurentPos;
}

bool AxisClass::isMotorStopped(double threshold)
{

    //開始尋零
        // 将当前位置添加到向量中
        recentPositions.push_back(m_AxisParam.dCurentPos);
        if (recentPositions.size() > 10) {
            // 若向量长度超过 10，移除最早的位置
            recentPositions.erase(recentPositions.begin());
        }

        if (recentPositions.size() < 10) {
            // 若记录的位置数量不足 10 个，暂不进行判断
            return false;
        }

        // 找出最近 10 次位置中的最小值和最大值
        double minPos = *std::min_element(recentPositions.begin(), recentPositions.end());
        double maxPos = *std::max_element(recentPositions.begin(), recentPositions.end());

        // 计算最大差值
        double diff = std::abs(maxPos - minPos);

        // 判断差值是否小于阈值
        return diff < threshold;
}

bool AxisClass::isZeroOver()
{
    return false;

}

void AxisClass::printAllParams() const
{
    static QString result;
    if(result.length() == 0)
    {
        result += QString("ConnectNum: %1 ").arg(m_AxisParam.nConnectNum);
        result += QString("Card: %1 ").arg(m_AxisParam.wCard);
        result += QString("Axis: %1 ").arg(m_AxisParam.wAxis);
        result += QString("Equiv: %1 ").arg(m_AxisParam.dEquiv);
        result += QString("StartSpeed: %1 ").arg(m_AxisParam.dStartSpeed);
        result += QString("Speed: %1 ").arg(m_AxisParam.dSpeed);
        result += QString("ChangePos: %1 ").arg(m_AxisParam.dChangePos);
        result += QString("AccTime: %1 ").arg(m_AxisParam.dAccTime);
        result += QString("ChangeTime: %1 ").arg(m_AxisParam.dChangeTime);
        result += QString("DecTime: %1 ").arg(m_AxisParam.dDecTime);
        result += QString("ChangeSpeed: %1 ").arg(m_AxisParam.dChangeSpeed);
        result += QString("StopSpeed: %1 ").arg(m_AxisParam.dStopSpeed);
        result += QString("SParaTime: %1 ").arg(m_AxisParam.dSParaTime);
        result += QString("Distance: %1 ").arg(m_AxisParam.dDistance);
        result += QString("IPAdress: %1 ").arg(m_AxisParam.strIPAdress);
        result += QString("DeviceName: %1 ").arg(m_AxisParam.strDeviceName);
        result += QString("EnableState: %1 ").arg(m_AxisParam.bEnableState);
        result += QString("UnitTrans: %1 ").arg(m_AxisParam.nUnitTrans);
        result += QString("OnPose: %1 ").arg(m_AxisParam.nOnPose);
        result += QString("OffPose: %1 ").arg(m_AxisParam.nOffPose);
        result += QString("Err: %1 ").arg(m_AxisParam.nErr);
        result += QString("Minlimit: %1 ").arg(m_AxisParam.nMinlimit);
        result += QString("Maxlimit: %1 ").arg(m_AxisParam.nMaxlimit);
        result += "Pose: [";
        for (int i = 0; i < 4; ++i)
        {
            if (i > 0) result += ", ";
            result += QString::number(m_AxisParam.nPose[i]);
        }
        result += "]\n";
    }
    LX_LOG_INFO("%s", result.toStdString().c_str());
}

bool AxisClass::getHomeCMD()
{
    return bmovCMD;
}

void AxisClass::setHomeCMD(bool cmd)
{
    bmovCMD = cmd;
    LX_LOG_INFO("axis[%d]setHomeCMD [%d]" ,m_AxisParam.wAxis,cmd);
}

void AxisClass::setsynPosflag(bool flag)
{
    synPosflag = flag;
    LX_LOG_INFO("axis[%d]setsynPosflag [%d]" ,m_AxisParam.wAxis,synPosflag);
}
bool AxisClass::getsynPosflag()
{
    return synPosflag;
}


// ///////////////////////////////////////////////////////////////////////
// ConfigReader &ConfigReader::getInstance() {
//     static ConfigReader instance;
//     return instance;
// }

bool ConfigReader::readConfigAndSetAxisClasses(const QString &configFilePath)
{
    QFile file(configFilePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        // 文件不存在，尝试新建
        if (createDefaultConfigFile(configFilePath)) {
            qDebug() << "未找到配置文件，已新建默认配置文件";
        } else {
            qDebug() << "无法打开配置文件且无法新建";
            return false;
        }
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonDocument jsonDoc = QJsonDocument::fromJson(data);
    if (jsonDoc.isNull() ||!jsonDoc.isObject()) {
        qDebug() << "配置文件格式不正确";
        return false;
    }

    rootObj = jsonDoc.object();
    if (rootObj.isEmpty()) {
        qDebug() << "配置文件内容为空";
        return false;
    }

    // 假设配置文件中对应AxisClass对象的配置信息存储在一个名为"axis_classes"的数组中
    if (!rootObj.contains("axis_classes") ||!rootObj["axis_classes"].isArray()) {
        qDebug() << "配置文件中缺少axis_classes数组";
        return false;
    }

    QJsonArray axisClassesArray = rootObj["axis_classes"].toArray();
    if (axisClassesArray.size()!= 10) {
        qDebug() << "配置文件中axis_classes数组元素个数不正确";
        return false;
    }

    for (int i = 0; i < 10; ++i) {
        if (!axisClassesArray[i].isObject()) {
            qDebug() << "axis_classes数组中元素不是合法的JSON对象";
            return false;
        }
    }

    return true;
}

bool ConfigReader::createDefaultConfigFile(const QString &filePath) {
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        return false;
    }

    QJsonArray axisClassesArray;

    for (int i = 0; i < 10; ++i) {
        QJsonObject axisObj;
        axisObj["axis"] = i + 1;
        axisObj["offsetPose"] =0;
        if(i == 8)
        {
            axisObj["on_Pos"] = 0;
            axisObj["off_Pos"] = 5;
        }
        if(i ==9)
        {
            axisObj["gearNo1_Pose"] =  15;
            axisObj["gearNo2_Pose"] = 5;
            axisObj["gearNo3_Pose"] = 10;
            axisObj["gearNo4_Pose"] = 0;
        }
        axisClassesArray.append(axisObj);
    }
     QJsonObject IRObj;
    IRObj["XOffset"] = 0;
    IRObj["YOffset"] = 0;
    rootObj["IR"] = IRObj;
    rootObj["axis_classes"] = axisClassesArray;
    rootObj["CardNum"] = 0;
    rootObj["ConnectNum"] =0;
    rootObj["IP"] = "92.168.5.11";
    rootObj["debug"] = 0;
    QJsonDocument jsonDoc(rootObj);
    QByteArray data = jsonDoc.toJson();
    file.write(data);
    file.close();
    return true;
}

QJsonObject ConfigReader::getJsonObj()
{
    return rootObj;
}



AxisTarget stringToAxisTarget(const QString& target)
{
	if (target == "platform.x") return AxisTarget::X;
	if (target == "platform.y") return AxisTarget::Y;
	if (target == "platform.z") return AxisTarget::Z;
	if (target == "platform.height") return AxisTarget::Height;
	return AxisTarget::Unknown;
}
