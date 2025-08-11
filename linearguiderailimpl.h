#pragma once
/*

*/
// 具体实现类
class LinearGuideRailImpl
{
public:

    struct sOutData
    {
        int addr;   //电机地址
        int functionId;//功能码
        int registerAddr;//0-读取电机状态，1-实际步数（functionId为10时代表运动到指定位置），2-停止且归零，16-运动到指定位置，64-前进
        int registerNum;//寄存器数量

        int getValue; //读取到的具体指（读电机状态时，改值无效）

        //仅读电机状态时，下述字段有效
        int powerOnStatus;  //开机状态: 1-开机未定义状态
        int runningStatus;  //运行空闲状态：1-空闲状态 2-运行状态
        int resetStatus;    //复位状态：1-复位中  2-不在复位中
        int otherStatus;    //其他状态：1-复位状态出错 2-正转时触发up开关  3-反转时触碰up开关

    };

    //读取电机当前位置
    int readMotorPosition(int addr, char* outBuffer);

    //复位电机
    int motorZeroing(int addr, char* outBuffer);

    //停止转动
    int stopRunning(int addr, char* outBuffer);

    //电机运动到指定位置（暂时不用，用moveByStep，根据调试结果选用该接口还是moveByStep，该接口需要安装额外零位传感器？）
    int moveToSetPosition(int addr, int position, char* outBuffer);

    //电机向前运动，step为负时反转
    int moveByStep(int addr, int step, char* outBuffer);

    //获取电机状态
    int getMotorStatus(int addr, char* outBuffer);

    //数据解析
    bool dataParse(char* buffer, int len, sOutData* outData, int registerValue);

    void modBusCRC(const char* data, int cnt, char* outData);

};
