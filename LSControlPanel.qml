import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import com.company.bridge 1.0

//支撑平台方位
CardPage {
    property var titleText: ""
    anchors.leftMargin: 45
    title: titleText
    Column {
        anchors.top: parent.top
        anchors.topMargin: 50
        anchors.left: parent.left
        anchors.leftMargin: 0
        padding: 10
        spacing: 15
        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 15
            FluButton{
                width: 150
                height: 50

                font {
                    family:  "SimSun"  // 字体家族
                    pixelSize: 20             // 字体大小(像素)
                    italic: false             // 是否斜体
                }
                text:"使能"
                onClicked: {

                }
            }

            FluButton{

                width: 150
                height: 50

                font {
                    family:  "SimSun"  // 字体家族
                    pixelSize: 20             // 字体大小(像素)
                    italic: false             // 是否斜体
                }
                text:"停止"
                onClicked: {

                }
            }
        }
      
        RowLayout{
            spacing: 15

            anchors.horizontalCenter: parent.horizontalCenter
            Label { 
                text: "位置" 
                color: "#404040" 
                font.pixelSize: 18 
                Layout.alignment: Qt.AlignVCenter
            }
                                    
            FluMultilineTextBox{
                Layout.preferredWidth:150
                disabled: false
            }
 
            Label { 
                text: "速度" 
                color: "#404040" 
                font.pixelSize: 18 
                Layout.alignment: Qt.AlignVCenter
            }

            FluMultilineTextBox{
                Layout.preferredWidth:150
                disabled: false
            }
        }

        Row{
            spacing: 15
            
            FluButton{

                width: 150
                height: 50

                font {
                    family:  "SimSun"  // 字体家族
                    pixelSize: 20             // 字体大小(像素)
                    italic: false             // 是否斜体
                }
                text:"前进"
                onClicked: {

                }
            }

            FluButton{

                width: 150
                height: 50

                font {
                    family:  "SimSun"  // 字体家族
                    pixelSize: 20             // 字体大小(像素)
                    italic: false             // 是否斜体
                }
                text:"后退"
                onClicked: {

                }
            }

            FluButton{

                width: 150
                height: 50

                font {
                    family:  "SimSun"  // 字体家族
                    pixelSize: 20             // 字体大小(像素)
                    italic: false             // 是否斜体
                }
                text:"绝对定位"
                onClicked: {

                }
            }
        }

        RowLayout{
            spacing: 15
            Layout.alignment: Qt.AlignHCenter
            Label {
                text: "当前位置" 
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
                    text: "1档"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#1A237E"
                }
            }

            Label {
                text: "运行状态" 
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
                    text: "就绪"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#2E7D32"
                }
            }
        }
    }
}