#pragma once

#include "protobuf/pb/ttb_control.pb.h"

// 各设备的独立IP地址
#define SWITCH_MECHANISM_IP   "192.168.2.191"
#define FILTER_WHEEL_IP       "192.168.2.191"
#define WAVE_PLATE_IP         "192.168.2.191"

// 各设备的独立端口号
#define SWITCH_MECHANISM_PORT 31002
#define FILTER_WHEEL_PORT     31003
#define WAVE_PLATE_PORT       31001

//雷赛控制器，运动平台ip地址
#define RACE_CONTROLLER_IP "192.168.2.192"

//伺服的地址和端口
#define LOCAL_PORT 5583
#define SERVO_IP "192.168.2.160"
#define SERVO_PORT 5582