import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import com.company.bridge 1.0
ApplicationWindow {
    id: mainWindow
    width: 1920
    height: 1080
    visible: true
    title: "F10星间激光跟踪测试系统"

    // 状态颜色配置（与待机模式相同）
    property color normalColor: "#424242"
    property color hoverColor: "#535353"
    property color pressedColor: "#4a90e2"
    property color checkedColor: "#4a90e2"

    QmlCppBridge{

        id: bridge

        objectName: "bridge"

        onSendtoQml:function(params)
        {
            
        }
    }

    // 标题栏样式
    header: ToolBar {
        height: 50
        background: Rectangle {
            color: "#333333"
        }

        Label {
            anchors.centerIn: parent
            text: "F10星间激光跟踪测试系统"
            color: "white"
            font.pixelSize: 26
            font.bold: true
        }
    }

    // 主布局
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // 左侧标签栏
        Rectangle {
            id: tabBar
            width: 300
            Layout.fillHeight: true
            color: "#f5f5f5"  // 背景改为浅灰色
            border { color: "#e0e0e0"; width: 1 }  // 边框改为更浅的灰色

            Column {
                width: parent.width
                spacing: 0
                property int currentIndex: 0

                Repeater {
                    model: ["平行光管", "运动平台", "微振动台"]
        
                    Button {
                        id: tabButton
                        width: parent.width
                        height: 80

                        checked: index === parent.currentIndex
                        background: Rectangle {
                            color: checked ? "#e3f2fd" : (hovered ? "#f0f0f0" : "#f5f5f5")  // 选中状态改为浅蓝色
                            Rectangle {
                                width: checked ? 3 : 0
                                height: parent.height
                                color: "#2196f3"  // 指示条改为标准蓝色
                                anchors.left: parent.left
                            }
                        }

                        onClicked: {
                            parent.currentIndex = index
                            stackLayout.currentIndex = index
                        }

                        contentItem: Text {
                            text: modelData
                            color: "#333333"  // 文字改为深灰色
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 20
                        }
                    }
                }
            }
        }

        // 主内容区域
        StackLayout {
            id: stackLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.children[0].currentIndex
            
            //平行光管
            Rectangle {
                id: parallelPage
                //设置左边界
                anchors.left: parent.left
                // 主布局
                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 25
                    contentWidth: dashboard.width
                    contentHeight: dashboard.height
                    GridLayout {
                        id: dashboard
                        columns: 3
                        rowSpacing: 25
                        columnSpacing: 12
                        width: 1620
                        anchors.horizontalCenter: parent.horizontalCenter

                        CardPage {
                            id: cardPage
                            title: "切换机构"
    
                            Column {
                                anchors.top: parent.top
                                anchors.topMargin: 70
                                anchors.left: parent.left
                                anchors.leftMargin: 0
                                padding: 10
                                spacing: 30

                                Row {
                                    spacing: 15
                                    FluButton {
                                        width: 150
                                        height: 50
                                        font {
                                            family: "SimSun"
                                            pixelSize: 20
                                        }
                                        text: "开启"
                                        onClicked: {
                                            bridge.sendtoCpp({"method":"switchmechanism.open‌"})
                                        }
                                    }

                                    FluButton {
                                        width: 150
                                        height: 50
                                        font {
                                            family: "SimSun"
                                            pixelSize: 20
                                        }
                                        text: "关闭"
                                        onClicked: {
                                            bridge.sendtoCpp({"method":"switchmechanism.close"})
                                        }
                                    }
            
                                    FluButton {
                                        width: 150
                                        height: 50
                                        font {
                                            family: "SimSun"
                                            pixelSize: 20
                                        }
                                        text: "寻零"
                                        onClicked: {
                                            bridge.sendtoCpp({"method":"switchmechanism.findzero"})
                                        }
                                    }  
                                }
        
                                RowLayout {
                                    spacing: 15
                                    Layout.alignment: Qt.AlignHCenter
                                    Label { 
                                        text: "电机位置" 
                                        color: "#404040" 
                                        font {
                                            pixelSize: 18
                                            bold: true
                                        }
                                        Layout.alignment: Qt.AlignVCenter
                                    }
            
                                    Rectangle {
                                        Layout.preferredWidth: 200
                                        height: 40
                                        radius: 8
                                        border.color: "#4CAF50"
                                        border.width: 2
                                        color: "#E8F5E9"
                
                                        Text {
                                            anchors.centerIn: parent
                                            text: "0.00 mm"
                                            font.pixelSize: 16
                                            color: "#2E7D32"
                                        }
                                    }
                                }
        
                                RowLayout {
                                    spacing: 15
                                    Layout.alignment: Qt.AlignHCenter
                                    Label { 
                                        text: "电机状态" 
                                        color: "#404040" 
                                        font {
                                            pixelSize: 18
                                            bold: true
                                        }
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 200
                                        height: 40
                                        radius: 8
                                        border.color: "#2196F3"
                                        border.width: 2
                                        color: "#E3F2FD"
                
                                        Text {
                                            anchors.centerIn: parent
                                            text: "运行中"
                                            font.pixelSize: 16
                                            color: "#1565C0"
                                        }
                                    }
                                }
                            }
                        }

                        CardPage {
                            id: cardPage2
                            title:"滤光轮"
    
                            anchors.left: cardPage.right
                            anchors.leftMargin: 45

                            Column {
                                anchors.top: parent.top
                                anchors.topMargin: 55
                                anchors.fill: parent
                                padding: 25
                                spacing: 25
                                
                                RowLayout {
                                    spacing: 15
                                    Layout.alignment: Qt.AlignHCenter
    
                                    Label {
                                        text: "设置挡位" 
                                        color: "#404040" 
                                        font.pixelSize: 18
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    FluComboBox {
                                        Layout.preferredWidth: 200  // 使用Layout.preferredWidth代替width
                                        Layout.preferredHeight: 50  // 使用Layout.preferredHeight代替height
                                        font.pixelSize: 22
        
                                        editable: false
                                        model: ListModel {
                                            id: model
                                            ListElement { text: "1档" }
                                            ListElement { text: "2档" }
                                            ListElement { text: "3档" }
                                            ListElement { text: "4档" }
                                        }
                                    }

                                    FluButton {
                                        Layout.preferredWidth: 150
                                        Layout.preferredHeight: 50
                                        
                                        font {
                                            family: "SimSun"
                                            pixelSize: 20
                                        }
                                        text: "下发"
                                        onClicked: {
                                            bridge.sendtoCpp({"method":"filterwheel.setgear‌","value": model.currentText})
                                        }
                                    }
                                }
        

                                RowLayout{
                                    spacing: 15
                                    Layout.alignment: Qt.AlignHCenter
                                    Label {
                                        text: "当前挡位" 
                                        color: "#404040" 
                                        font.pixelSize: 18 
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    // 优化后的挡位显示
                                    Rectangle {
                                        Layout.preferredWidth: 200
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
                                }

                                RowLayout{
                                    spacing: 15
                                    Layout.alignment: Qt.AlignHCenter
                                    Label {
                                        text: "运行状态" 
                                        color: "#404040" 
                                        font.pixelSize: 18 
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    // 优化后的状态显示
                                    Rectangle {
                                        Layout.preferredWidth: 200
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



                        //波片切换机构
                        CardPage {
                            anchors.left: cardPage2.right
                            anchors.leftMargin: 45
                            title:"波片切换机构"
                            Column {
                                
                                anchors.top: parent.top
                                anchors.topMargin: 70
                                anchors.left: parent.left
                                anchors.leftMargin: 0
                                padding: 10
                                spacing: 30

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
                                        text:"开启"
                                        onClicked: {
                                            bridge.sendtoCpp({"method":"waveplate.open‌"})
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
                                        text:"关闭"
                                        onClicked: {
                                            bridge.sendtoCpp({"method":"waveplate.close"})
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
                                        text:"寻零"
                                        onClicked: {
                                            bridge.sendtoCpp({"method":"waveplate.findzero"})
                                        }
                                    }  
                                }
                                RowLayout {
                                    spacing: 15
                                    Layout.alignment: Qt.AlignHCenter
                                    Label { 
                                        text: "电机位置" 
                                        color: "#404040" 
                                        font {
                                            pixelSize: 18
                                            bold: true
                                        }
                                        Layout.alignment: Qt.AlignVCenter
                                    }
            
                                    Rectangle {
                                        Layout.preferredWidth: 200
                                        height: 40
                                        radius: 8
                                        border.color: "#4CAF50"
                                        border.width: 2
                                        color: "#E8F5E9"
                
                                        Text {
                                            anchors.centerIn: parent
                                            text: "0.00 mm"
                                            font.pixelSize: 16
                                            color: "#2E7D32"
                                        }
                                    }
                                }
        
                                RowLayout {
                                    spacing: 15
                                    Layout.alignment: Qt.AlignHCenter
                                    Label { 
                                        text: "电机状态" 
                                        color: "#404040" 
                                        font {
                                            pixelSize: 18
                                            bold: true
                                        }
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 200
                                        height: 40
                                        radius: 8
                                        border.color: "#2196F3"
                                        border.width: 2
                                        color: "#E3F2FD"
                
                                        Text {
                                            anchors.centerIn: parent
                                            text: "运行中"
                                            font.pixelSize: 16
                                            color: "#1565C0"
                                        }
                                    }
                                }
                            }
                        }

                        //打开快反镜控制软件
                        CardPage {
                            title:"快反镜"
                            Column {
                                anchors.fill: parent
                                padding: 25
                                spacing: 15

                                FluButton{
                                    anchors.top: parent.top
                                    anchors.topMargin: 120
                                    anchors.left: parent.left
                                    anchors.leftMargin: 110
                                    width: 150
                                    height: 50

                                    font {
                                        family:  "SimSun"  // 字体家族
                                        pixelSize: 20             // 字体大小(像素)
                                        italic: false             // 是否斜体
                                    }
                                    text:"打开软件"
                                    onClicked: {

                                    }
                                }
                            }
                        }
                        //打开光偏振检测仪
                        CardPage {
                            title:"光偏振检测仪"
                            Column {
                                anchors.fill: parent
                                padding: 25
                                spacing: 15

                                FluButton{
                                    anchors.top: parent.top
                                    anchors.topMargin: 120
                                    anchors.left: parent.left
                                    anchors.leftMargin: 110
                                    width: 150
                                    height: 50
                                    
                                    font {
                                        family:  "SimSun"  // 字体家族
                                        pixelSize: 20             // 字体大小(像素)
                                        italic: false             // 是否斜体
                                    }
                                    text:"打开软件"
                                    onClicked: {

                                    }
                                }
                            }
                        }
                        //打开光束质量分析仪
                        CardPage {
                            title:"光束质量分析仪"
                            Column {
                                anchors.fill: parent
                                padding: 25
                                spacing: 15

                                FluButton{
                                    anchors.top: parent.top
                                    anchors.topMargin: 120
                                    anchors.left: parent.left
                                    anchors.leftMargin: 110
                                    width: 150
                                    height: 50
                                    font {
                                        family:  "SimSun"  // 字体家族
                                        pixelSize: 20             // 字体大小(像素)
                                        italic: false             // 是否斜体
                                    }
                                    text:"打开软件"
                                    onClicked: {

                                    }
                                }
                            }
                        }
                    }
                }
            }

            //运动平台
            Rectangle {
                id: platformPage
                //设置左边界
                anchors.left: parent.left
                // 主布局
                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 25
                    contentWidth: dashboard1.width
                    contentHeight: dashboard1.height
                    GridLayout {
                        id: dashboard1
                        columns: 3
                        rowSpacing: 25
                        columnSpacing: 25
                        width: 1620
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        LSControlPanel{
                            titleText: "支撑平台方位"
                            bridge: bridge
                            code: "platform.x"
                        }

                        LSControlPanel{
                            titleText: "支撑平台俯仰"
                            bridge: bridge
                            code: "platform.y"
                        }

                        LSControlPanel{
                            titleText: "支撑平台高低"
                            bridge: bridge
                            code: "platform.z"
                        }

                        LSControlPanel{
                            titleText: "升降台"
                            bridge: bridge
                            code: "platform.hight"
                        }
                        
                        //支撑平台方位
                        /*
                        CardPage {
                            anchors.left: cardPage2.right
                            anchors.leftMargin: 45
                            title:"支撑平台方位"
                            Column {
                                
                                anchors.top: parent.top
                                anchors.topMargin: 70
                                anchors.left: parent.left
                                anchors.leftMargin: 0
                                padding: 10
                                spacing: 30

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
                                        text:"绝对定位"
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
                                }
                                
                                RowLayout{
                                    spacing: 15
                                    Layout.alignment: Qt.AlignHCenter
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
                            }
                        }
                        */
                        
                        /*
                        //大升降台
                        CardPage {
                            title:"升降台"
                            Column {

                                spacing: 15
                                anchors.top: parent.top
                                anchors.topMargin: 60
                                anchors.left: parent.left
                                anchors.leftMargin: 20

                                FluTextBox{
                                    placeholderText: qsTr("输入高度")
                                }
                                
                                FluButton{
                                    text:"下发"
                                    onClicked: {
                                        
                                    }
                                }
                            }
                        }

                        //双轴转台控制
                        CardPage {
                            title:"双轴转台"
                            ColumnLayout {
                                anchors.top: parent.top
                                anchors.topMargin: 100
                                anchors.left: parent.left
                                anchors.leftMargin: 75
                                spacing: 15
                                Layout.alignment: Qt.AlignCenter
    
                                // 第一行：上按钮
                                Button {
                                    text: "↑"
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 80
                                    Layout.preferredHeight: 40

                                    background: Rectangle {
                                        color: parent.down ? "#3a3a3a" : 
                                              parent.hovered ? "#535353" : "#424242"
                                        radius: 6
                                        border.width: parent.hovered ? 2 : 1
                                        border.color: parent.hovered ? "#6b6b6b" : "#555555"
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "#f0f0f0"
                                        font {
                                            family: "Microsoft YaHei"
                                            pixelSize: 16
                                            bold: true
                                        }
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                // 第二行：左、下、右按钮
                                RowLayout {
                                    spacing: 15
                                    Layout.alignment: Qt.AlignHCenter
        
                                    Button {
                                        text: "←"
                                        Layout.preferredWidth: 80
                                        Layout.preferredHeight: 40


                                        background: Rectangle {
                                            color: parent.down ? "#3a3a3a" : 
                                                  parent.hovered ? "#535353" : "#424242"
                                            radius: 6
                                            border.width: parent.hovered ? 2 : 1
                                            border.color: parent.hovered ? "#6b6b6b" : "#555555"
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "#f0f0f0"
                                            font {
                                                family: "Microsoft YaHei"
                                                pixelSize: 16
                                                bold: true
                                            }
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }

                                    Button {
                                        text: "↓"
                                        Layout.preferredWidth: 80
                                        Layout.preferredHeight: 40


                                        background: Rectangle {
                                            color: parent.down ? "#3a3a3a" : 
                                                  parent.hovered ? "#535353" : "#424242"
                                            radius: 6
                                            border.width: parent.hovered ? 2 : 1
                                            border.color: parent.hovered ? "#6b6b6b" : "#555555"
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "#f0f0f0"
                                            font {
                                                family: "Microsoft YaHei"
                                                pixelSize: 16
                                                bold: true
                                            }
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }

                                    Button {
                                        text: "→"
                                        Layout.preferredWidth: 80
                                        Layout.preferredHeight: 40


                                        background: Rectangle {
                                            color: parent.down ? "#3a3a3a" : 
                                                  parent.hovered ? "#535353" : "#424242"
                                            radius: 6
                                            border.width: parent.hovered ? 2 : 1
                                            border.color: parent.hovered ? "#6b6b6b" : "#555555"
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "#f0f0f0"
                                            font {
                                                family: "Microsoft YaHei"
                                                pixelSize: 16
                                                bold: true
                                            }
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }
                        }
                        */
                    }
                }
            }


            //微振动台
            Rectangle {
                id: vibrationPage
                //设置左边界
                anchors.left: parent.left
                // 主布局
                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 25
                    contentWidth: dashboard2.width
                    contentHeight: dashboard2.height
                    GridLayout {
                        id: dashboard2
                        columns: 3
                        rowSpacing: 25
                        columnSpacing: 25
                        width: 1620
                        anchors.horizontalCenter: parent.horizontalCenter
                        //震动设置 x
                        CardPage {
                            title:"微振动台-x轴"
                            Column {
                                spacing: 15
                                anchors.top: parent.top
                                anchors.topMargin: 60
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                RowLayout {
                                    spacing: 15
                                    Layout.alignment: Qt.AlignHCenter

                                    Label { 
                                        text: "电机位置" 
                                        color: "#404040" 
                                        font {
                                            pixelSize: 18
                                            bold: true
                                        }
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    FluComboBox{
                                        id: waveCombox1
                                        Layout.preferredWidth: 180  // 使用Layout.preferredWidth代替width
                                        Layout.preferredHeight: 50  // 使用Layout.preferredHeight代替height

                                        font.pixelSize: 22
                                    
                                        editable: false
                                        model: ListModel {
                                            id: model1
                                            ListElement { text: "波形1" }
                                            ListElement { text: "波形2" }
                                            ListElement { text: "波形3" }
                                            ListElement { text: "波形4" }
                                        }
                                    }

                                    Label {
                                        text: "震动幅值" 
                                        color: "#404040" 
                                        font {
                                            pixelSize: 18
                                            bold: true
                                        }
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    FluTextBox{
                                        id: peakText1
                                        Layout.preferredWidth: 100  // 使用Layout.preferredWidth代替width
                                        Layout.preferredHeight: 50  // 使用Layout.preferredHeight代替height
                                    }
                                }
                                
                                RowLayout {
                                    spacing: 15
                                    Layout.alignment: Qt.AlignHCenter

                                    Label {
                                        text: "频率" 
                                        color: "#404040" 
                                        font {
                                            pixelSize: 18
                                            bold: true
                                        }
                                        Layout.alignment: Qt.AlignVCenter
                                    } 

                                    FluTextBox{
                                        id: freqText1
                                        Layout.preferredWidth: 150  // 使用Layout.preferredWidth代替width
                                        Layout.preferredHeight: 40  // 使用Layout.preferredHeight代替height
                                    }

                                    Label { 
                                        text: "偏置" 
                                        color: "#404040" 
                                        font {
                                            pixelSize: 18
                                            bold: true
                                        }
                                        Layout.alignment: Qt.AlignVCenter
                                    } 

                                    FluTextBox{
                                        id: offsetText1
                                        Layout.preferredWidth: 150  // 使用Layout.preferredWidth代替width
                                        Layout.preferredHeight: 40  // 使用Layout.preferredHeight代替height
                                    }
                                }
                                
                                Row{
                                    x: (parent.width - width) / 2
                                    spacing: 15
                                    FluButton{

                                        width: 150
                                        height: 50

                                        font {
                                            family:  "SimSun"  // 字体家族
                                            pixelSize: 20             // 字体大小(像素)
                                            italic: false             // 是否斜体
                                        }
                                        text:"开始"
                                        onClicked: {
                                            //下发震动指令
                                            bridge.sendtoCpp({"cmd":"‌shakingtable.open","chl":"x","wave":waveCombox1.currentIndex,"peak":peakText1.text,"freq":freqText1.text,"offset":offsetText1.text})
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
                                    Layout.alignment: Qt.AlignHCenter
                                    Label {
                                        text: "当前挡位" 
                                        color: "#404040" 
                                        font.pixelSize: 18 
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    // 优化后的挡位显示
                                    Rectangle {
                                        Layout.preferredWidth: 125
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
                                        Layout.preferredWidth: 125
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
                        
                        //震动设置 y
                        CardPage {
                            title:"微振动台-y轴"
                            Column {
                                spacing: 15
                                anchors.top: parent.top
                                anchors.topMargin: 60
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                RowLayout {
                                    spacing: 15
                                    Layout.alignment: Qt.AlignHCenter

                                    Label { 
                                        text: "电机位置" 
                                        color: "#404040" 
                                        font {
                                            pixelSize: 18
                                            bold: true
                                        }
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    FluComboBox{
                                        id: waveCombox2
                                        Layout.preferredWidth: 180  // 使用Layout.preferredWidth代替width
                                        Layout.preferredHeight: 50  // 使用Layout.preferredHeight代替height

                                        font.pixelSize: 22
                                    
                                        editable: false
                                        model: ListModel {
                                            id: model2
                                            ListElement { text: "波形1" }
                                            ListElement { text: "波形2" }
                                            ListElement { text: "波形3" }
                                            ListElement { text: "波形4" }
                                        }
                                    }
                                    
                                    Label { 
                                        text: "震动幅值" 
                                        color: "#404040" 
                                        font {
                                            pixelSize: 18
                                            bold: true
                                        }
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    FluTextBox{
                                        id: peakText2
                                        Layout.preferredWidth: 100  // 使用Layout.preferredWidth代替width
                                        Layout.preferredHeight: 50  // 使用Layout.preferredHeight代替height
                                    }
                                }
                                
                                RowLayout {
                                    spacing: 15
                                    Layout.alignment: Qt.AlignHCenter

                                    Label { 
                                        text: "频率" 
                                        color: "#404040" 
                                        font {
                                            pixelSize: 18
                                            bold: true
                                        }
                                        Layout.alignment: Qt.AlignVCenter
                                    } 

                                    FluTextBox{
                                        id: freqText2
                                        Layout.preferredWidth: 150  // 使用Layout.preferredWidth代替width
                                        Layout.preferredHeight: 40  // 使用Layout.preferredHeight代替height
                                    }

                                    Label { 
                                        text: "偏置" 
                                        color: "#404040" 
                                        font {
                                            pixelSize: 18
                                            bold: true
                                        }
                                        Layout.alignment: Qt.AlignVCenter
                                    } 

                                    FluTextBox{
                                        id: offsetText2
                                        Layout.preferredWidth: 150  // 使用Layout.preferredWidth代替width
                                        Layout.preferredHeight: 40  // 使用Layout.preferredHeight代替height
                                    }
                                }
                                
                                Row{
                                    x: (parent.width - width) / 2
                                    spacing: 15
                                    FluButton{

                                        width: 150
                                        height: 50

                                        font {
                                            family:  "SimSun"  // 字体家族
                                            pixelSize: 20             // 字体大小(像素)
                                            italic: false             // 是否斜体
                                        }
                                        text:"开始"
                                        onClicked: {
                                            //下发震动指令
                                            bridge.sendtoCpp({"cmd":"‌shakingtable.open","chl":"y","wave":waveCombox2.currentIndex,"peak":peakText2.text,"freq":freqText2.text,"offset":offsetText2.text})
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
                                    Layout.alignment: Qt.AlignHCenter
                                    Label {
                                        text: "当前挡位" 
                                        color: "#404040" 
                                        font.pixelSize: 18 
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    // 优化后的挡位显示
                                    Rectangle {
                                        Layout.preferredWidth: 125
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
                                        Layout.preferredWidth: 125
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

                        //双轴转台
                        CardPage {
                            title:"双轴转台"
                            Column {
                                spacing: 15
                                anchors.top: parent.top
                                anchors.topMargin: 60
                                anchors.left: parent.left
                                anchors.leftMargin: 20

                                

                                RowLayout{
                                    spacing: 15
                                    Layout.alignment: Qt.AlignHCenter
                                    Label {
                                        text: "运行状态" 
                                        color: "#404040" 
                                        font.pixelSize: 18 
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    // 优化后的状态显示
                                    Rectangle {
                                        Layout.preferredWidth: 200
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
                    }
                }
            }
        }
    }
}
