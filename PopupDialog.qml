import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Layouts 1.15
Popup {
    id: root
    width: 600
    height: 400
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 0

    background: Rectangle {
        radius: 12
        color: "#f5f7fa"
        border.color: "#e0e3e7"
        border.width: 1
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 12
            samples: 25
            color: "#40000000"
        }
    }

    Column {
        spacing: 10
        padding: 20
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width

        Text {
            id: titleText
            width: parent.width - 40
            horizontalAlignment: Text.AlignHCenter
            text: "提示"
            font {
                family: "Microsoft YaHei"
                pixelSize: 30
                bold: true
            }
            color: "#333"
        }

        // 分隔线
        Rectangle {
            id: separator
            width: parent.width - 40
            height: 1
            color: "#E0E0E0"
        }
    }
    
    Text {
        id: messageText
        anchors.centerIn: parent
        width: parent.width - 40
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        font {
            family: "Microsoft YaHei"
            pixelSize: 28
        }
        lineHeight: 1.5
        color: "#666"
    }

    Button {
        id: confirmButton
        width: 120
        height: 50
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        text: "确定"
        font {
            family: "Microsoft YaHei"
            pixelSize: 20
        }
        background: Rectangle {
            radius: 6
            color: parent.down ? "#3a7bd5" : "#4a90e2"
            Behavior on color { ColorAnimation { duration: 150 } }
        }
        contentItem: Text {
            text: parent.text
            font: parent.font
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        onClicked: root.close()
    }
    
    function showMessage(title, message) {
        titleText.text = title
        messageText.text = message
        open()
    }
}
