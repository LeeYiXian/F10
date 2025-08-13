import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    property string title: ""
    property bool isOnline: false  // 添加在线状态属性
    property bool statusVisible: true  // 添加状态指示灯可见性属性
    Layout.minimumWidth: 500
    height: 320
    
    radius: 16
    color: Qt.rgba(0.96, 0.96, 0.96, 0.8)
    border.color: Qt.rgba(0.85, 0.85, 0.85, 1)
    layer.enabled: true

    Column {
        anchors.fill: parent
        spacing: 0

        // 标题区域
        Item {
            width: parent.width
            height: 50
            anchors.horizontalCenter: parent.horizontalCenter

            Row {
                anchors.centerIn: parent
                spacing: 10  // 控制指示灯和标题的间距

                // 状态指示灯
                Rectangle {
                    id: statusIndicator
                    visible: statusVisible
                    width: 18
                    height: 18
                    radius: 9
                    color: isOnline ? "#8BC34A" : "#9E9E9E"

                    anchors.verticalCenter: parent.verticalCenter

                    // 呼吸动画效果
                    SequentialAnimation on opacity {
                        running: isOnline
                        loops: Animation.Infinite
                        NumberAnimation { from: 0.4; to: 1; duration: 1000 }
                        NumberAnimation { from: 1; to: 0.4; duration: 1000 }
                    }
                }

                Label {
                    text: title
                    color: "#5A4D41"
                    font { 
                        pixelSize: 20
                        bold: true
                        family: "Microsoft YaHei"
                    }
                }
            }

            // 分隔线
            Rectangle {
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                width: parent.width - 40
                height: 1
                color: "#E0E0E0"
            }
        }
    }
}
