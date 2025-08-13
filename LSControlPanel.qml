import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import com.company.bridge 1.0

CardPage {
    property var titleText: ""
    property var bridge
    property var code: ""
    property var axispos: ""
    property var errorstatus: ""
    property bool onlinestatus : false
    anchors.leftMargin: 45
    isOnline: onlinestatus
    title: titleText
    Column {
        anchors.top: parent.top
        anchors.topMargin: 50
        anchors.left: parent.left
        anchors.leftMargin: 0
        padding: 20
        spacing: 20
        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 15
            FluButton{
                width: 135
                height: 45

                font {
                    family:  "SimSun"         // 字体家族
                    pixelSize: 20             // 字体大小(像素)
                    italic: false             // 是否斜体
                }
                text:"使能"
                onClicked: {
                    bridge.sendtoCpp({"method": "supportplatform.enable","target":code});
                }
            }

            FluButton{
                width: 135
                height: 45

                font {
                    family:  "SimSun"         // 字体家族
                    pixelSize: 20             // 字体大小(像素)
                    italic: false             // 是否斜体
                }
                text:"去使能"
                onClicked: {
                    bridge.sendtoCpp({"method": "supportplatform.unable","target":code});
                }
            }

            FluButton{

                width: 135
                height: 45

                font {
                    family:  "SimSun"         // 字体家族
                    pixelSize: 20             // 字体大小(像素)
                    italic: false             // 是否斜体
                }
                text:"停止"
                onClicked: {
                    bridge.sendtoCpp({"method": "supportplatform.stop","target":code});
                }
            }
        }
      
        RowLayout{
            spacing: 15

            anchors.horizontalCenter: parent.horizontalCenter
            Label { 
                text: "位置" 
                color: "#404040" 
                font.pixelSize: 20 
                Layout.alignment: Qt.AlignVCenter
            }
                                    
            FluTextBox{
                id: positionInput
                Layout.preferredWidth: 150
                disabled: false
                font.family: "Times New Roman"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                font.pixelSize: 20 
                validator: DoubleValidator {
                    bottom: 0.0
                    top: 10000.0
                    decimals: 2
                    notation: DoubleValidator.StandardNotation
                }
            }
 
            Label {
                text: "速度" 
                color: "#404040" 
                font.pixelSize: 20 
                Layout.alignment: Qt.AlignVCenter
            }

            FluTextBox{
                id: speedInput
                Layout.preferredWidth:150
                disabled: false
                font.family: "Times New Roman"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                font.pixelSize: 20 
                validator: DoubleValidator {
                    bottom: 0.0
                    top: 10000.0
                    decimals: 2
                    notation: DoubleValidator.StandardNotation
                }
            }
        }

        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 15
            
            FluButton{

                width: 135
                height: 45

                font {
                    family:  "SimSun"         // 字体家族
                    pixelSize: 20             // 字体大小(像素)
                    italic: false             // 是否斜体
                }
                text:"前进"
                onClicked: {
                    bridge.sendtoCpp({"method": "supportplatform.forward","speed":speedInput.text,"target":code});
                }
            }

            FluButton{

                width: 135
                height: 45

                font {
                    family:  "SimSun"         // 字体家族
                    pixelSize: 20             // 字体大小(像素)
                    italic: false             // 是否斜体
                }
                text:"后退"
                onClicked: {
                    bridge.sendtoCpp({"method": "supportplatform.backward","speed":speedInput.text,"target":code});
                }
            }

            FluButton{

                width: 135
                height: 45

                font {
                    family:  "SimSun"         // 字体家族
                    pixelSize: 20             // 字体大小(像素)
                    italic: false             // 是否斜体
                }
                text:"绝对定位"
                onClicked: {
                    bridge.sendtoCpp({"method": "supportplatform.position","position":positionInput.text,"speed":speedInput.text,"target":code});
                }
            }
        }

        RowLayout{
            spacing: 15
            Layout.alignment: Qt.AlignHCenter
            Label {
                text: "轴位置" 
                color: "#404040" 
                font.pixelSize: 18 
                Layout.alignment: Qt.AlignVCenter
            }

            // 优化后的挡位显示
            Rectangle {
                Layout.preferredWidth: 145
                height: 40
                radius: 8
                border.color: "#3F51B5"
                border.width: 2
                color: "#E8EAF6"
                
                Text {
                    anchors.centerIn: parent
                    text: axispos
                    font.pixelSize: 16
                    font.bold: true
                    color: "#1A237E"
                }
            }

            Label {
                text: "错误状态" 
                color: "#404040" 
                font.pixelSize: 18 
                Layout.alignment: Qt.AlignVCenter
            }

            // 优化后的状态显示
            Rectangle {
                Layout.preferredWidth: 145
                height: 40
                radius: 8
                border.color: "#4CAF50"
                border.width: 2
                color: "#E8F5E9"
                
                Text {
                    anchors.centerIn: parent
                    text: errorstatus
                    font.pixelSize: 16
                    font.bold: true
                    color: "#2E7D32"
                }
            }
        }
    }
}