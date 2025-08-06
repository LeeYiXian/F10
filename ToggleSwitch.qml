import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
Item {
    width: 80
    height: 40
    
    // 公共属性
    property bool checked: false
    property color trackColor: "#F0F0F0" // 更浅的背景色
    property color fillColor: "#0078D7"  // Windows主题蓝色
    property color buttonColor: "#FFFFFF" // 白色按钮
    property color borderColor: "#C0C0C0" // 浅灰色边框
    
    // 状态改变信号
    signal toggled(bool state)
    
    // 背景轨道
    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: toggleSwitch.checked ? fillColor : trackColor
        border.color: borderColor
        border.width: 2
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }
    
    // 开关按钮
    Rectangle {
        id: button
        width: height
        height: parent.height - 8
        radius: height / 2
        color: buttonColor
        x: toggleSwitch.checked ? parent.width - width - 4 : 4
        y: 4
        
        // 阴影效果
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 5
            samples: 11
            color: "#80000000"
        }
        
        // 动画效果
        Behavior on x {
            NumberAnimation { 
                duration: 200 
                easing.type: Easing.InOutQuad
            }
        }
    }
    
    // 点击区域
    MouseArea {
        anchors.fill: parent
        onClicked: {
            toggleSwitch.checked = !toggleSwitch.checked
            toggleSwitch.toggled(toggleSwitch.checked)
        }
    }
}