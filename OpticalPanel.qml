import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import FluentUI 1.0
Rectangle {
    color: "#f9f9f9"
    radius: 5
    border.color: "#ddd"
    width: parent.width
    border.width: 1

    // 颜色定义
    readonly property color primary: "#2A3F54"
    readonly property color secondary: "#4A6572"
    readonly property color accent: "#3498db"
    readonly property color textColor: "#F5F6FA"

    // 主布局
    ScrollView {
        anchors.fill: parent
        anchors.margins: 25
        
        contentWidth: dashboard.width
        contentHeight: dashboard.height


        GridLayout {
            id: dashboard
            columns: Math.floor(width / 300)
            rowSpacing: 25
            columnSpacing: 25
            width: Math.min(window.width - 300, 1400)
            anchors.horizontalCenter: parent.horizontalCenter
            
            ToggleSwitch {
                id: toggleSwitch
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                width: 100
                height: 50
                checked: true
                onCheckedChanged: {
                    logCard.addLog(`开关状态: ${checked ? "开" : "关"}`);
                }
            }
        }
    }
} 

