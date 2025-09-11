import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import com.company.bridge 1.0
import QtQuick.Window 2.15
ApplicationWindow {
    id: mainWindow
    visible: true
    title: "F10星间激光跟踪测试系统"
        // 取消注释以启用无边框窗口
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowMinimizeButtonHint
    // 状态颜色配置（与待机模式相同）
    function toDMS(angle){
        if(angle > 0)
        {
            var deg = Math.floor(angle);
            var minFloat = (angle - deg)*60;
            var min = Math.floor(minFloat);    
            var sec = (minFloat - min) * 60;
            return deg + "°" + min + "′" + sec.toFixed(0) + "″";
        }
        else
        {//-10.1234567   1 + -0.1234567    * 60
            var absAngle = Math.abs(angle);
            var deg = Math.floor(absAngle);
            var minFloat = (absAngle - deg)*60;
            var min = Math.floor(minFloat);    
            var sec = (minFloat - min) * 60;
            return "-" + deg + "°" + min + "′" + sec.toFixed(0) + "″";
        }
    }
    
    Component.onCompleted: {
        showMaximized()
    }

    onVisibilityChanged: {
        if (visibility === Window.Windowed) {
            mainWindow.showMaximized()
        }
    }
    
    // 捕获快捷键 Alt+V
    Shortcut {
        sequence: "Alt+V"
        onActivated: {
            captureScreen()
        }
    }

    // 捕获快捷键 Alt+V
    Shortcut {
        sequence: "Alt+A"
        onActivated: {
            bridge.onScreenShot()
        }
    }

    // 定义截图函数
    function captureScreen() {
        outerBackground.grabToImage(function(result) {
            var path = "screenshot/screenshot_" + Date.now() + ".png"
            result.saveToFile(path)
            console.log("截图保存到: " + path)
        })
    }

    property color normalColor: "#424242"
    property color hoverColor: "#535353"
    property color pressedColor: "#4a90e2"
    property color checkedColor: "#4a90e2"

    PopupDialog {
        id: operationPopup
        anchors.centerIn: parent
    }

    // 灰色边框层
    Rectangle {
        anchors.fill: parent
        color: "transparent"          // 窗口内容透明
        border.color: "#999999"       // 灰色边框
        border.width: 3               // 边框宽度
        radius: 0                     // 可以加圆角：如 radius: 5
    }

    // 定义一个 Timer
    Timer {
        id: servoTimeoutTimer
        interval: 2000   // 2 秒
        repeat: true    // 单次触发
        onTriggered: {
            cardPageServo.isOnline = false
        }
    }

    QmlCppBridge{

        id: bridge

        objectName: "bridge"

        onSendtoQml: function(params) {
            if (params.method === "switchmechanism.online")
            {   
                cardPageSwitch.isOnline = true
            }
            else if (params.method === "switchmechanism.offline")
            {
                cardPageSwitch.isOnline = false
            }
            else if (params.method === "switchmechanism.status")
            {
                switchPos.text = params.gear
                switchStatus.text = params.motorStatus
            }
            else if (params.method === "filterwheel.online")
            {
                cardPageFilter.isOnline = true
            }
            else if (params.method === "filterwheel.offline")
            {
                cardPageFilter.isOnline = false
            }
            else if (params.method === "filterwheel.status")
            {
                if (params.hasOwnProperty('gear')) {
                    filterGear.text = params.gear;
                }
                if (params.hasOwnProperty('motorStatus')) {
                    filterStatus.text = params.motorStatus;
                }
            }
            else if (params.method === "waveplate.online")
            {
                cardPageWaveplate.isOnline = true
            }
            else if (params.method === "waveplate.offline")
            {
                cardPageWaveplate.isOnline = false
            }
            else if (params.method === "waveplate.status")
            {
                if (params.hasOwnProperty('gear')) {
                    waveplatePos.text = params.gear;
                }
                if (params.hasOwnProperty('motorStatus')) {
                    waveplateStatus.text = params.motorStatus;
                }
            }
            else if (params.method === "dmc.online")
            {
                platform.onlinestatus = true
            }
            else if (params.method === "dmc.offline")
            {
                platform.onlinestatus = false
            }
            else if (params.method === "axisStatusUpdate") 
            {

                let stateText = params.moveState ? "运动中" : "空闲";  // 转换成文字

                switch (params.axis) {
                    case 1: // 方位
                        platform.azimuthPos    = params.position.toFixed(3) + "°"
                        platform.azimuthError  = params.error
                        platform.azimuthStatus = stateText
                        break;
                    case 0: // 俯仰
                        platform.elevationPos    = params.position.toFixed(3) + "°"
                        platform.elevationError  = params.error
                        platform.elevationStatus = stateText
                        break;
                    case 2: // 小升降
                        platform.smallLiftPos    = params.position.toFixed(3) + "mm"
                        platform.smallLiftError  = params.error
                        platform.smallLiftStatus = stateText
                        break;
                    case 3: // 大升降
                        platform.largeLiftPos    = (params.position + 1400).toFixed(3) + "mm"
                        platform.largeLiftError  = params.error
                        platform.largeLiftStatus = stateText
                        break;
                }
            }
            else if (params.method === "shakingtable.online")
            {
                cardPageShakingtableX.isOnline = true
                cardPageShakingtableY.isOnline = true
            }
            else if (params.method === "shakingtable.offline")
            {
                cardPageShakingtableX.isOnline = false
                cardPageShakingtableY.isOnline = false
            }
            else if (params.method === "shakingtable.position")
            {
                if (params.chl === 0)
                {
                    stxPosition.text = params.position.toFixed(2) + "urad"
                }
                else if (params.chl === 1)
                {
                    styPosition.text = params.position.toFixed(2) + "urad"                    
                }
                else if (params.chl === 2)
                {
                    stzPosition.text = params.position.toFixed(2) + "urad"
                }
            }
            else if (params.method === "servo.report")
            {
                //azimuthText.text = params.angleX.toFixed(2) + "°"
                //pitchText.text = params.angleY.toFixed(2) + "°"
                azimuthText.text = toDMS(params.angleX)
                pitchText.text = toDMS(params.angleY)  
                
                cardPageServo.isOnline = true

                // 将 currentMode 转成中文
                let modeDesc = "";
                switch (parseInt(params.currentMode)) {
                    case 0:
                        modeDesc = "去使能";
                        break;
                    case 16:
                        modeDesc = "使能";
                        break;
                    case 32:
                        modeDesc = "速度模式";
                        break;
                    case 48:
                        modeDesc = "位置模式";
                        break;
                    default:
                        modeDesc = "未知模式";
                }
                
                servomodeText.text = modeDesc;
                
                if(parseInt(params.statusCode) === 4983)
                {
                    statusText.text = "正常"
                    statusText.color = "#2E7D32"   // 绿色
                }
                else
                {
                    statusText.text = "异常"
                    statusText.color = "red"       // 红色
                }

                // 每次收到消息时，重启定时器
                servoTimeoutTimer.restart()
            }
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

        // 最小化按钮
        Button {
            id: minimizeButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: closeButton.left
            anchors.rightMargin: 10
            width: 30
            height: 30
            background: Image {
                anchors.fill: parent
                source: "./image/minimize.png" // 替换成你的最小化按钮图片路径
                fillMode: Image.PreserveAspectFit
            }
            onClicked: mainWindow.showMinimized()
        }

        // 关闭按钮
        Button {
            id: closeButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            width: 30
            height: 30
            background: Image {
                anchors.fill: parent
                source: "./image/close.png"   // 替换成你的关闭按钮图片路径
                fillMode: Image.PreserveAspectFit
            }

            onClicked: Qt.quit()  // 点击关闭程序
        }

        // 拖动区域（标题栏除了关闭按钮的部分）
        MouseArea {
            id: dragArea
            anchors.left: parent.left
            anchors.right: minimizeButton.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            property point clickOffset: Qt.point(0, 0)

            onPressed: clickOffset = Qt.point(mouse.x, mouse.y)

            onPositionChanged: {
                var mousePos = mapToGlobal(mouse.x, mouse.y)
                mainWindow.x = mousePos.x - clickOffset.x
                mainWindow.y = mousePos.y - clickOffset.y
            }
        }
    }
    Rectangle {
        id: outerBackground
        anchors.fill: parent
        color: "transparent"  // 完全透明

        // 主布局
        RowLayout {
            anchors.fill: parent
            spacing: 0

            // 左侧标签栏
            Rectangle {
                id: tabBar
                width: 200
                Layout.fillHeight: true
                color: "#f5f5f5"  // 背景改为浅灰色
                border { color: "#e0e0e0"; width: 1 }  // 边框改为更浅的灰色

                Column {
                    width: parent.width
                    spacing: 0
                    property int currentIndex: 0

                    Repeater {
                        model: ["平行光管", "四轴平台", "微震动台", "双轴转台"]
        
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
                            columns: 2
                            rowSpacing: 25
                            columnSpacing: 12
                            width: 1080
                            anchors.horizontalCenter: parent.horizontalCenter

                            CardPage {
                                id: cardPageSwitch
                                title: "偏振态仪切换"
    
                                Column {
                                    anchors.top: parent.top
                                    anchors.topMargin: 55
                                    anchors.leftMargin: 0
                                    padding: 25
                                    spacing: 40

                                    Row {
                                        spacing: 60
                                        anchors.leftMargin: 60   // 左边距 50
                                        anchors.left: parent.left
                                    
                                        FluButton {
                                            width: 150
                                            height: 50
                                            font {
                                                family: "SimSun"
                                                pixelSize: 20
                                            }
                                            text: "启用"
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
                                            text: "禁用"
                                            onClicked: {
                                                bridge.sendtoCpp({"method":"switchmechanism.close"})
                                            }
                                        }
                                        /*
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
                                        */
                                    }
        
                                    RowLayout {
                                        spacing: 25
                                        Layout.alignment: Qt.AlignHCenter
                                        Label { 
                                            text: "偏振态仪位置" 
                                            color: "#404040" 
                                            font {
                                                pixelSize: 18
                                                bold: true
                                            }
                                            Layout.alignment: Qt.AlignVCenter
                                        }
            
                                        Rectangle {
                                            Layout.preferredWidth: 240
                                            height: 40
                                            radius: 8
                                            border.color: "#4CAF50"
                                            border.width: 2
                                            color: "#E8F5E9"
                
                                            Text {
                                                id: switchPos
                                                anchors.centerIn: parent
                                                font.pixelSize: 16
                                                color: "#2E7D32"
                                            }
                                        }
                                    }

                                    RowLayout {
                                        spacing: 60
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
                                            Layout.preferredWidth: 240
                                            height: 40
                                            radius: 8
                                            border.color: "#2196F3"
                                            border.width: 2
                                            color: "#E3F2FD"
                
                                            Text {
                                                id: switchStatus
                                                anchors.centerIn: parent
                                                font.pixelSize: 16
                                                color: "#1565C0"
                                            }
                                        }
                                    }
                                }
                            }

                            CardPage {
                                id: cardPageFilter
                                title:"滤光轮"

                                anchors.leftMargin: 45

                                Column {
                                    anchors.top: parent.top
                                    anchors.topMargin: 55
                                    anchors.fill: parent
                                    padding: 25
                                    spacing: 40
                                
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
                                            id: filterComboBox
                                            Layout.preferredWidth: 250  // 使用Layout.preferredWidth代替width
                                            Layout.preferredHeight: 50  // 使用Layout.preferredHeight代替height
                                            font.pixelSize: 22
        
                                            editable: false
                                            model: ListModel {
                                                id: model
                                                ListElement { text: "空挡" }
                                                ListElement { text: "发1540.56 收1563.05" }
                                                ListElement { text: "发1545.32 收1559.79" }
                                                ListElement { text: "发1559.79 收1545.32" }
                                                ListElement { text: "发1563.05 收1540.56" }
                                            }
                                        }

                                        FluButton {
                                            Layout.preferredWidth: 100
                                            Layout.preferredHeight: 50
                                        
                                            font {
                                                family: "SimSun"
                                                pixelSize: 20
                                            }
                                            text: "下发"
                                            onClicked: {
                                                bridge.sendtoCpp({"method":"filterwheel.setgear‌", "value": filterComboBox.currentIndex})
                                            }
                                        }
                                    }
        

                                    RowLayout{
                                        spacing: 15
                                        Layout.alignment: Qt.AlignHCenter
                                        Label {
                                            text: "当前挡位" 
                                            color: "#404040" 
                                            font {
                                                pixelSize: 18
                                                bold: true
                                            }
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        // 优化后的挡位显示
                                        Rectangle {
                                            Layout.preferredWidth: 240
                                            height: 40
                                            radius: 8
                                            border.color: "#4CAF50"
                                            border.width: 2
                                            color: "#E8F5E9"
                
                                            Text {
                                                id: filterGear
                                                anchors.centerIn: parent
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
                                            text: "电机状态" 
                                            color: "#404040" 
                                            font {
                                                pixelSize: 18
                                                bold: true
                                            }
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        // 优化后的状态显示
                                        Rectangle {
                                            Layout.preferredWidth: 240
                                            height: 40
                                            radius: 8
                                            border.color: "#2196F3"
                                            border.width: 2
                                            color: "#E3F2FD"
                
                                            Text {
                                                id: filterStatus
                                                anchors.centerIn: parent
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
                                id: cardPageWaveplate
                                anchors.leftMargin: 45
                                title:"波片切换机构"
                                Column {
                                
                                    anchors.top: parent.top
                                    anchors.topMargin: 55
                                    anchors.left: parent.left
                                    anchors.leftMargin: 0
                                    padding: 25
                                    spacing: 40

                                    Row{
                                        spacing: 60
                                        anchors.leftMargin: 60   // 左边距 50
                                        anchors.left: parent.left
                                        FluButton{

                                            width: 150
                                            height: 50

                                            font {
                                                family:  "SimSun"  // 字体家族
                                                pixelSize: 20             // 字体大小(像素)
                                                italic: false             // 是否斜体
                                            }
                                            text:"发射左旋"
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
                                            text:"发射右旋"
                                            onClicked: {
                                                bridge.sendtoCpp({"method":"waveplate.close"})
                                            }
                                        }
                                        /*
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
                                        */
                                    }

                                    RowLayout {
                                        spacing: 25
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
                                            Layout.preferredWidth: 240
                                            height: 40
                                            radius: 8
                                            border.color: "#4CAF50"
                                            border.width: 2
                                            color: "#E8F5E9"
                
                                            Text {
                                                id: waveplatePos
                                                anchors.centerIn: parent
                                                font.pixelSize: 16
                                                color: "#2E7D32"
                                            }
                                        }
                                    }

                                    RowLayout {
                                        spacing: 25
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
                                            Layout.preferredWidth: 240
                                            height: 40
                                            radius: 8
                                            border.color: "#2196F3"
                                            border.width: 2
                                            color: "#E3F2FD"
                
                                            Text {
                                                id: waveplateStatus
                                                anchors.centerIn: parent
                                                font.pixelSize: 16
                                                color: "#1565C0"
                                            }
                                        }
                                    }
                                }
                            }

                            //打开快反镜控制软件
                            CardPage {
                                statusVisible: false
                                title:"工具"
                                Column {
                                    anchors.centerIn: parent    // 关键：整体放到 CardPage 中心
                                    spacing: 20
                                
                                    Button {
                                        text: "快反镜控制"
                                        id: fsmButton
                                        background: Item {}   // 去掉默认背景
                                        font.family: "FangSong"   // 仿宋
                                        font.pixelSize: 30
                                        font.underline: true
                                        font.italic: true          // 设置斜体

                                        contentItem: Text {
                                            text: fsmButton.text
                                            font: fsmButton.font
                                            color: fsmButton.hovered ? "red" : "blue"
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignHCenter
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: fsmButton.clicked()
                                        }
                                    
                                        onClicked: {
                                            bridge.sendtoCpp({"method":"software.openfsm"})
                                        }
                                    }

                                    Button {
                                        text: "光束质量分析"
                                        id: qcmButton
                                        background: Item {}   // 去掉默认背景
                                        font.family: "FangSong"   // 仿宋
                                        font.pixelSize: 30
                                        font.underline: true
                                        font.italic: true          // 设置斜体

                                        contentItem: Text {
                                            text: qcmButton.text
                                            font: qcmButton.font
                                            color: qcmButton.hovered ? "red" : "blue"
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignHCenter
                                        }

                                        // 鼠标样式（套 MouseArea 实现）
                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: qcmButton.clicked()
                                        }
                                    
                                        onClicked: {
                                            bridge.sendtoCpp({"method":"software.openqcm"})
                                        }
                                    }

                                    Button {
                                        text: "光偏振检测"
                                        id: qpdButton
                                        background: Item {}   // 去掉默认背景
                                        font.family: "FangSong"   // 仿宋
                                        font.pixelSize: 30
                                        font.underline: true
                                        font.italic: true          // 设置斜体

                                        contentItem: Text {
                                            text: qpdButton.text
                                            font: qpdButton.font
                                            color: qpdButton.hovered ? "red" : "blue"
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignHCenter
                                        }

                                        // 鼠标样式（套 MouseArea 实现）
                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: qpdButton.clicked()
                                        }
                                    
                                        onClicked: {
                                            bridge.sendtoCpp({"method":"software.opengpm"})
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

                    LSControlPanel{
                        id: platform
                        titleText: "四轴转台控制"
                        bridge: bridge
                        width: 1060
                        height: 930
                        anchors.horizontalCenter: parent.horizontalCenter   // 水平居中
                        anchors.top: parent.top                             // 顶部对齐
                        anchors.topMargin: 25                               // 根据需要设置距离
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
                            columnSpacing: 12
                            width: 1080
                            anchors.horizontalCenter: parent.horizontalCenter
                            //震动设置 x
                            CardPage {
                                id: cardPageShakingtableX
                                title:"微震动台-方位"
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
                                            text: "波形" 
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
                                                ListElement { text: "正弦波" }
                                                ListElement { text: "方波" }
                                                ListElement { text: "三角波" }
                                                ListElement { text: "锯齿波" }
                                            }
                                        }

                                        Label { 
                                            text: "模式" 
                                            color: "#404040" 
                                            font {
                                                pixelSize: 18
                                                bold: true
                                            }
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        FluComboBox{
                                            id: shakingModeCombox1
                                            Layout.preferredWidth: 180  // 使用Layout.preferredWidth代替width
                                            Layout.preferredHeight: 50  // 使用Layout.preferredHeight代替height

                                            font.pixelSize: 22
                                    
                                            editable: false
                                            model: ListModel {
                                                id: shakingMode1
                                                ListElement { text: "震动模式" }
                                                ListElement { text: "位置模式" }
                                            }
                                        }
                                    }
                                
                                    RowLayout {
                                        spacing: 15
                                        Layout.alignment: Qt.AlignHCenter

                                        Label {
                                            text: "位置(urad)" 
                                            color: "#404040" 
                                            font {
                                                pixelSize: 18
                                                bold: true
                                            }
                                            Layout.alignment: Qt.AlignVCenter
                                            visible: shakingModeCombox1.currentText === "位置模式"
                                        }

                                        FluTextBox{
                                            id: posText1
                                            font.pixelSize: 18
                                            placeholderText: "-500-500"
                                            Layout.preferredWidth: 100  // 使用Layout.preferredWidth代替width
                                            Layout.preferredHeight: 50  // 使用Layout.preferredHeight代替height
                                            visible: shakingModeCombox1.currentText === "位置模式"
                                            validator: IntValidator {
                                                bottom: -500
                                                top: 500
                                            }
                                            // 实时检查
                                            onTextChanged: {
                                                if (text !== "") {
                                                    var val = parseInt(text)
                                                    if (val > 500) {
                                                        text = "500"
                                                    } else if (val < -500) {
                                                        text = "-500"
                                                    }
                                                }
                                            }
                                        }

                                        Label {
                                            text: "幅值(urad)" 
                                            color: "#404040" 
                                            font {
                                                pixelSize: 18
                                                bold: true
                                            }
                                            Layout.alignment: Qt.AlignVCenter
                                            visible: shakingModeCombox1.currentText === "震动模式"
                                        }

                                        FluTextBox{
                                            id: peakText1
                                            font.pixelSize: 18
                                            placeholderText: "1-500"
                                            Layout.preferredWidth: 100  // 使用Layout.preferredWidth代替width
                                            Layout.preferredHeight: 50  // 使用Layout.preferredHeight代替height
                                            visible: shakingModeCombox1.currentText === "震动模式"
                                            validator: IntValidator {
                                                bottom: 1
                                                top: 500
                                            }
                                            // 实时检查
                                            onTextChanged: {
                                                if (text !== "") {
                                                    var val = parseInt(text)
                                                    if (val > 500) {
                                                        text = "500"
                                                    } else if (val < 1) {
                                                        text = "1"
                                                    }
                                                }
                                            }
                                        }

                                        Label {
                                            text: "频率(Hz)" 
                                            color: "#404040" 
                                            font {
                                                pixelSize: 18
                                                bold: true
                                            }
                                            Layout.alignment: Qt.AlignVCenter
                                        } 

                                        FluTextBox{
                                            id: freqText1
                                            font.pixelSize: 18
                                            placeholderText: "1-500"
                                            Layout.preferredWidth: 150  // 使用Layout.preferredWidth代替width
                                            Layout.preferredHeight: 40  // 使用Layout.preferredHeight代替height
                                            validator: IntValidator {
                                                bottom: 1
                                                top: 500
                                            }
                                            // 实时检查
                                            onTextChanged: {
                                                if (text !== "") {
                                                    var val = parseInt(text)
                                                    if (val > 500) {
                                                        text = "500"
                                                    } else if (val < 1) {
                                                        text = "1"
                                                    }
                                                }
                                            }
                                        }
                                    }
                                
                                    Row{
                                        x: (parent.width - width) / 2
                                        spacing: 50
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
                                                if (waveCombox1.currentIndex === -1 || peakText1.text === "" || freqText1.text === "") 
                                                {
                                                    return
                                                }
                                                //下发震动指令
                                                bridge.sendtoCpp({"method":"‌shakingtable.open","chl":"x","wave":waveCombox1.currentIndex,"peak":peakText1.text,"freq":freqText1.text,"mode":shakingModeCombox1.currentIndex})
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
                                                bridge.sendtoCpp({"method":"‌shakingtable.close","chl":"x"})
                                            }
                                        }
                                    }
                                
                                    RowLayout{
                                        spacing: 25
                                        Layout.alignment: Qt.AlignHCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 0   // 整体往右 50 像素
                                        /*Label {
                                            text: "电压" 
                                            color: "#404040" 
                                            font.pixelSize: 18 
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        // 优化后的挡位显示
                                        Rectangle {
                                            Layout.preferredWidth: 150
                                            height: 40
                                            radius: 8
                                            border.color: "#3F51B5"
                                            border.width: 2
                                            color: "#E8EAF6"
                
                                            Text {
                                                id: stxVoltage
                                                anchors.centerIn: parent
                                                font.pixelSize: 16
                                                font.bold: true
                                                color: "#1A237E"
                                            }
                                        }*/

                                        Label {
                                            text: "位置" 
                                            color: "#404040" 
                                            font.pixelSize: 18 
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        // 优化后的状态显示
                                        Rectangle {
                                            Layout.preferredWidth: 240
                                            height: 40
                                            radius: 8
                                            border.color: "#4CAF50"
                                            border.width: 2
                                            color: "#E8F5E9"
                
                                            Text {
                                                id: stxPosition
                                                anchors.centerIn: parent
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
                                id: cardPageShakingtableY
                                title:"微震动台-俯仰"
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
                                            text: "波形" 
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
                                                ListElement { text: "正弦波" }
                                                ListElement { text: "方波" }
                                                ListElement { text: "三角波" }
                                                ListElement { text: "矩形波" }
                                            }
                                        }

                                        Label { 
                                            text: "模式" 
                                            color: "#404040" 
                                            font {
                                                pixelSize: 18
                                                bold: true
                                            }
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        FluComboBox{
                                            id: shakingModeCombox2
                                            Layout.preferredWidth: 180  // 使用Layout.preferredWidth代替width
                                            Layout.preferredHeight: 50  // 使用Layout.preferredHeight代替height

                                            font.pixelSize: 22
                                    
                                            editable: false
                                            model: ListModel {
                                                id: shakingMode2
                                                ListElement { text: "震动模式" }
                                                ListElement { text: "位置模式" }
                                            }
                                        }
                                    }
                                
                                    RowLayout {
                                        spacing: 15
                                        Layout.alignment: Qt.AlignHCenter

                                        Label {
                                            text: "位置(urad)" 
                                            color: "#404040" 
                                            font {
                                                pixelSize: 18
                                                bold: true
                                            }
                                            Layout.alignment: Qt.AlignVCenter
                                            visible: shakingModeCombox2.currentText === "位置模式"
                                        }

                                        FluTextBox{
                                            id: posText2
                                            font.pixelSize: 18
                                            placeholderText: "-500-500"
                                            Layout.preferredWidth: 100  // 使用Layout.preferredWidth代替width
                                            Layout.preferredHeight: 50  // 使用Layout.preferredHeight代替height
                                            visible: shakingModeCombox2.currentText === "位置模式"
                                            validator: IntValidator {
                                                bottom: -500
                                                top: 500
                                            }
                                            // 实时检查
                                            onTextChanged: {
                                                if (text !== "") {
                                                    var val = parseInt(text)
                                                    if (val > 500) {
                                                        text = "500"
                                                    } else if (val < -500) {
                                                        text = "-500"
                                                    }
                                                }
                                            }
                                        }

                                        Label { 
                                            text: "幅值(urad)" 
                                            color: "#404040" 
                                            font {
                                                pixelSize: 18
                                                bold: true
                                            }
                                            Layout.alignment: Qt.AlignVCenter
                                            visible: shakingModeCombox2.currentText === "震动模式"
                                        }

                                        FluTextBox{
                                            id: peakText2
                                            font.pixelSize: 18
                                            placeholderText: "1-120"
                                            Layout.preferredWidth: 100  // 使用Layout.preferredWidth代替width
                                            Layout.preferredHeight: 50  // 使用Layout.preferredHeight代替height
                                            visible: shakingModeCombox2.currentText === "震动模式"
                                            // 限制为 1-120 的整数
                                            validator: IntValidator {
                                                bottom: 1
                                                top: 120
                                            }
                                            // 实时检查
                                            onTextChanged: {
                                                if (text !== "") {
                                                    var val = parseInt(text)
                                                    if (val > 120) {
                                                        text = "120"
                                                    } else if (val < 1) {
                                                        text = "1"
                                                    }
                                                }
                                            }
                                        }
                                    
                                        Label { 
                                            text: "频率(Hz)" 
                                            color: "#404040" 
                                            font {
                                                pixelSize: 18
                                                bold: true
                                            }
                                            Layout.alignment: Qt.AlignVCenter
                                        } 

                                        FluTextBox{
                                            id: freqText2
                                            font.pixelSize: 18
                                            placeholderText: "1-500"
                                            Layout.preferredWidth: 150  // 使用Layout.preferredWidth代替width
                                            Layout.preferredHeight: 40  // 使用Layout.preferredHeight代替height
                                            // 限制为 1-60 的整数
                                            validator: IntValidator {
                                                bottom: 1
                                                top: 500
                                            }
                                            // 实时检查
                                            onTextChanged: {
                                                if (text !== "") {
                                                    var val = parseInt(text)
                                                    if (val > 500) {
                                                        text = "500"
                                                    } else if (val < 1) {
                                                        text = "1"
                                                    }
                                                }
                                            }
                                        }
                                    }
                                
                                    Row{
                                        x: (parent.width - width) / 2
                                        spacing: 50
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
                                                if (waveCombox2.currentIndex === -1 || peakText2.text === "" || freqText2.text === "") 
                                                {
                                                    return
                                                }
                                                //下发震动指令
                                                bridge.sendtoCpp({"method":"‌shakingtable.open","chl":"y","wave":waveCombox2.currentIndex,"peak":peakText2.text,"freq":freqText2.text,"mode":shakingModeCombox2.currentIndex})
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
                                                bridge.sendtoCpp({"method":"‌shakingtable.close","chl":"y"})
                                            }
                                        }
                                    

                                    }
                                
                                    RowLayout{
                                        spacing: 25
                                        Layout.alignment: Qt.AlignHCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 0   // 整体往右 50 像素
                                        /*Label {
                                            text: "电压" 
                                            color: "#404040" 
                                            font.pixelSize: 18 
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        // 优化后的挡位显示
                                        Rectangle {
                                            Layout.preferredWidth: 150
                                            height: 40
                                            radius: 8
                                            border.color: "#3F51B5"
                                            border.width: 2
                                            color: "#E8EAF6"
                
                                            Text {
                                                id: styVoltage
                                                anchors.centerIn: parent
                                                font.pixelSize: 16
                                                font.bold: true
                                                color: "#1A237E"
                                            }
                                        }
                                        */

                                        Label {
                                            text: "位置" 
                                            color: "#404040" 
                                            font.pixelSize: 18 
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        // 优化后的状态显示
                                        Rectangle {
                                            Layout.preferredWidth: 240
                                            height: 40
                                            radius: 8
                                            border.color: "#4CAF50"
                                            border.width: 2
                                            color: "#E8F5E9"
                
                                            Text {
                                                id: styPosition
                                                anchors.centerIn: parent
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

                //伺服转台
                Rectangle {
                    id: servoPage
                    //设置左边界
                    anchors.left: parent.left

                    //双轴转台
                    CardPage {
                        id: cardPageServo
                        title:"双轴转台"
                        width: 1060
                        height: 650
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 25
                        ColumnLayout {            // ★ 用 ColumnLayout 取代 Column
                            spacing: 15
                            anchors.top: parent.top
                            anchors.topMargin: 60
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20
                            anchors.bottomMargin: 20
                            anchors.fill: parent   // 让 ColumnLayout 填满整个 CardPage

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                FluButton {
                                    Layout.preferredWidth: 120
                                    Layout.preferredHeight: 50
                                    font {
                                        family: "SimSun"
                                        pixelSize: 20
                                    }
                                    text: "去使能"
                                    onClicked: {
                                        bridge.sendtoCpp({
                                            "method": "servo.setmode",
                                            "value": 0x00
                                        })
                                    }
                                }
                                    
                                FluButton {
                                    Layout.preferredWidth: 120
                                    Layout.preferredHeight: 50
                                    font {
                                        family: "SimSun"
                                        pixelSize: 20
                                    }
                                    text: "使能"
                                    onClicked: {
                                        bridge.sendtoCpp({
                                            "method": "servo.setmode",
                                            "value": 0x10
                                        })
                                    }
                                }

                                FluButton {
                                    Layout.preferredWidth: 120
                                    Layout.preferredHeight: 50
                                    font {
                                        family: "SimSun"
                                        pixelSize: 20
                                    }
                                    text: "速度模式"
                                    onClicked: bridge.sendtoCpp({
                                        "method": "servo.setmode",
                                        "value": 0x20
                                    })
                                }

                                FluButton {
                                    Layout.preferredWidth: 120
                                    Layout.preferredHeight: 50
                                    font {
                                        family: "SimSun"
                                        pixelSize: 20
                                    }
                                    text: "位置模式"
                                    onClicked: bridge.sendtoCpp({
                                        "method": "servo.setmode",
                                        "value": 0x30
                                    })
                                }

                                Label {
                                    text: "当前模式："
                                    color: "#333333"
                                    font.pixelSize: 24
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                    
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 40
                                    radius: 8
                                    border.color: "#4CAF50"
                                    border.width: 2
                                    color: "#E8F5E9"
                
                                    Text {
                                        id: servomodeText
                                        anchors.centerIn: parent
                                        text: ""
                                        font.pixelSize: 24
                                        font.bold: true
                                        color: "#2E7D32"
                                    }
                                }     
                            }

                            // XY位置模式
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 30

                                Label {
                                    text: "方位(°):"
                                    color: "#333333"
                                    font.pixelSize: 20
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                TextField {
                                    id: xPosInput
                                    Layout.fillWidth: true
                                    placeholderText: "-180-180"
                                    color: "#333333"
                                    font.pixelSize: 24
                                    validator: DoubleValidator { bottom: -180; top: 180;decimals: 3}
                                    // 实时检查 
                                    onTextChanged: {
                                        if (text !== "") {
                                            var val = parseFloat(text)
                                            if (val > 180.00) {
                                                text = "180.000"
                                            } else if (val < -180.00) {
                                                text = "-180.000"
                                            }
                                        }
                                    }
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    background: Rectangle {
                                        color: "#f8f8f8"
                                        radius: 4
                                        border.color: xPosInput.activeFocus ? "#4a90e2" : "#cccccc"
                                    }
                                }
                                    
                                FluButton {
                                    Layout.preferredWidth: 120
                                    Layout.preferredHeight: 50
                                    font {
                                        family: "SimSun"
                                        pixelSize: 20
                                    }
                                    text: "移动"
                                    onClicked: {
                                        if (xPosInput.text === "") {
                                            return
                                        }
                                        bridge.sendtoCpp({"method":"servo.setposx","value":xPosInput.text,"vel":xVelInput.text})
                                    }
                                }

                                Label {
                                    text: "俯仰(°):"
                                    color: "#333333"
                                    font.pixelSize: 20
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                TextField {
                                    id: yPosInput
                                    Layout.fillWidth: true
                                    placeholderText: "-35-35"
                                    color: "#333333"
                                    font.pixelSize: 24
                                    validator: DoubleValidator { bottom: -35; top: 35;decimals: 3 }
                                    // 实时检查 
                                    onTextChanged: {
                                        if (text !== "") {
                                            var val = parseFloat(text)
                                            if (val > 35.00) {
                                                text = "35.000"
                                            } else if (val < -35.000) {
                                                text = "-35.000"
                                            }
                                        }
                                    }
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    background: Rectangle {
                                        color: "#f8f8f8"
                                        radius: 4
                                        border.color: yPosInput.activeFocus ? "#4a90e2" : "#cccccc"
                                    }
                                }

                                FluButton {
                                    Layout.preferredWidth: 120
                                    Layout.preferredHeight: 50
                                    font {
                                        family: "SimSun"
                                        pixelSize: 20
                                    }
                                    text: "移动"
                                    onClicked: {
                                        if (yPosInput.text === "") {
                                            return
                                        }
                                        bridge.sendtoCpp({"method":"servo.setposy","value":yPosInput.text,"vel":yVelInput.text})
                                    }
                                }
                            }

                            // XY速度输入行
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 30

                                Label {
                                    text: "X速度(°/s):"
                                    color: "#333333"
                                    font.pixelSize: 20
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                TextField {
                                    id: xVelInput
                                    Layout.fillWidth: true
                                    //text: "10"
                                    placeholderText: "0.001-20.000"
                                    Layout.preferredWidth: 120
                                    color: "#333333"
                                    font.pixelSize: 24
                                    validator: DoubleValidator { bottom: 0.001; top: 20.000 ; decimals: 3}

                                    // 按下回车
                                    Keys.onReturnPressed: validateAndFormat()
                                    // accepted 信号（回车确认）
                                    onAccepted: validateAndFormat()
                                    // 失去焦点时
                                    onActiveFocusChanged: if (!activeFocus) validateAndFormat()
                                    // 兼容 editingFinished
                                    onEditingFinished: validateAndFormat()

                                    function validateAndFormat() {
                                        if (text === "" || text === "." || text === "0." || text === "-") return

                                        var v = parseFloat(text)
                                        if (isNaN(v)) return

                                        if (v > 20.0) v = 20.0
                                        if (v < 0.001) v = 0.001

                                        text = v.toFixed(3)
                                    }

                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    background: Rectangle {
                                        color: "#f8f8f8"
                                        radius: 4
                                        border.color: xVelInput.activeFocus ? "#4a90e2" : "#cccccc"
                                    }
                                }

                                Label {
                                    text: "Y速度(°/s):"
                                    color: "#333333"
                                    font.pixelSize: 20
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                TextField {
                                    id: yVelInput
                                    Layout.fillWidth: true
                                    //text: "10"
                                    placeholderText: "0.001-20.000"
                                    Layout.preferredWidth: 120
                                    color: "#333333"
                                    font.pixelSize: 24
                                    validator: DoubleValidator { bottom: 0.001; top: 20.000 ; decimals: 3}
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly

                                    Keys.onReturnPressed: validateAndFormat()
                                    onAccepted: validateAndFormat()
                                    onActiveFocusChanged: if (!activeFocus) validateAndFormat()
                                    onEditingFinished: validateAndFormat()

                                    function validateAndFormat() {
                                        if (text === "" || text === "." || text === "0." || text === "-") return

                                        var v = parseFloat(text)
                                        if (isNaN(v)) return

                                        if (v > 20.0) v = 20.0
                                        if (v < 0.001) v = 0.001

                                        text = v.toFixed(3)
                                        console.log("yVelInput 校验完成:", text)
                                    }
                                        
                                    background: Rectangle {
                                        color: "#f8f8f8"
                                        radius: 4
                                        border.color: yVelInput.activeFocus ? "#4a90e2" : "#cccccc"
                                    }
                                }
                            }
                            // 上按钮
                            RowLayout {
                                spacing: 15
                                Layout.alignment: Qt.AlignHCenter
                                // 上按钮
                                Button {
                                    text: "↑"
                                    Layout.preferredHeight: 80
                                    Layout.preferredWidth: 120

                                    onPressed: bridge.sendtoCpp({
                                        "method": "servo.setvel",
                                        "value": {"x": 0, "y": yVelInput.text},
                                        "state": "pressed"
                                    })
                                    onReleased: bridge.sendtoCpp({
                                        "method": "servo.setvel",
                                        "value": {"x": 0, "y": 0},
                                        "state": "released"
                                    })

                                    background: Rectangle {
                                        color: parent.down ? "#d0d0d0" :
                                                parent.hovered ? "#e6f0ff" : "#f8f8f8"
                                        radius: 6
                                        border.width: parent.hovered ? 2 : 1
                                        border.color: parent.hovered ? "#4a90e2" : "#cccccc"
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "#333333"
                                        font {
                                            family: "Microsoft YaHei"
                                            pixelSize: 24
                                            bold: true
                                        }
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            // 左、中、右按钮
                            RowLayout {
                                spacing: 15
                                Layout.alignment: Qt.AlignHCenter
                                Button {
                                    text: "←"
                                    Layout.preferredHeight: 80
                                    Layout.preferredWidth: 120

                                    onPressed: bridge.sendtoCpp({
                                        "method": "servo.setvel",
                                        "value": {"x": -xVelInput.text, "y": 0},
                                        "state": "pressed"
                                    })

                                    onReleased: bridge.sendtoCpp({
                                        "method": "servo.setvel",
                                        "value": {"x": 0, "y": 0},
                                        "state": "released"
                                    })

                                    background: Rectangle {
                                        color: parent.down ? "#d0d0d0" :
                                                parent.hovered ? "#e6f0ff" : "#f8f8f8"
                                        radius: 6
                                        border.width: parent.hovered ? 2 : 1
                                        border.color: parent.hovered ? "#4a90e2" : "#cccccc"
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: "#333333"
                                        font.bold: true
                                        font.pixelSize: 24
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Button {
                                    text: "↓"
                                    Layout.preferredHeight: 80
                                    Layout.preferredWidth: 120

                                    onPressed: bridge.sendtoCpp({
                                        "method": "servo.setvel",
                                        "value": {"x": 0, "y": -yVelInput.text},
                                        "state": "pressed"
                                    })

                                    onReleased: bridge.sendtoCpp({
                                        "method": "servo.setvel",
                                        "value": {"x": 0, "y": 0},
                                        "state": "released"
                                    })

                                    background: Rectangle {
                                        color: parent.down ? "#d0d0d0" :
                                                parent.hovered ? "#e6f0ff" : "#f8f8f8"
                                        radius: 6
                                        border.width: parent.hovered ? 2 : 1
                                        border.color: parent.hovered ? "#4a90e2" : "#cccccc"
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: "#333333"
                                        font.bold: true
                                        font.pixelSize: 24
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Button {
                                    text: "→"
                                    Layout.preferredHeight: 80
                                    Layout.preferredWidth: 120

                                    onPressed: bridge.sendtoCpp({
                                        "method": "servo.setvel",
                                        "value": {"x": xVelInput.text, "y": 0},
                                        "state": "pressed"
                                    })

                                    onReleased: bridge.sendtoCpp({
                                        "method": "servo.setvel",
                                        "value": {"x": 0, "y": 0},
                                        "state": "released"
                                    })

                                    background: Rectangle {
                                        color: parent.down ? "#d0d0d0" :
                                                parent.hovered ? "#e6f0ff" : "#f8f8f8"
                                        radius: 6
                                        border.width: parent.hovered ? 2 : 1
                                        border.color: parent.hovered ? "#4a90e2" : "#cccccc"
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: "#333333"
                                        font.bold: true
                                        font.pixelSize: 24
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            RowLayout{
                                spacing: 15
                                Layout.alignment: Qt.AlignHCenter
                                Label {
                                    text: "方位" 
                                    color: "#404040" 
                                    font.pixelSize: 24
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                // 优化后的状态显示
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 40
                                    radius: 8
                                    border.color: "#4CAF50"
                                    border.width: 2
                                    color: "#E8F5E9"
                
                                    Text {
                                        id: azimuthText
                                        anchors.centerIn: parent
                                        text: "未知"
                                        font.pixelSize: 24
                                        font.bold: true
                                        color: "#2E7D32"
                                    }
                                }

                                Label {
                                    text: "俯仰" 
                                    color: "#404040" 
                                    font.pixelSize: 24
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                // 优化后的状态显示
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 40
                                    radius: 8
                                    border.color: "#4CAF50"
                                    border.width: 2
                                    color: "#E8F5E9"
                
                                    Text {
                                        id:pitchText
                                        anchors.centerIn: parent
                                        text: "未知"
                                        font.pixelSize: 24
                                        font.bold: true
                                        color: "#2E7D32"
                                    }
                                }

                                Label {
                                    text: "状态" 
                                    color: "#404040" 
                                    font.pixelSize: 24
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                // 优化后的状态显示
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 40
                                    radius: 8
                                    border.color: "#4CAF50"
                                    border.width: 2
                                    color: "#E8F5E9"
                
                                    Text {
                                        id: statusText
                                        anchors.centerIn: parent
                                        text: "未知"
                                        font.pixelSize: 24
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