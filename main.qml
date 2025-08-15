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

    PopupDialog {
        id: operationPopup
        anchors.centerIn: parent
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
                switchPos.Text = params.gear
                switchStatus.Text = params.motorStatus
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
                filterGear.Text = params.gear
                filterStatus.Text = params.motorStatus
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
                waveplatePos.Text = params.gear
                waveplateStatus.Text = params.motorStatus
            }
            else if (params.method === "dmc.online")
            {
                platformx.onlinestatus = true
                platformy.onlinestatus = true
                platformz.onlinestatus = true
                platformh.onlinestatus = true
            }
            else if (params.method === "dmc.offline")
            {
                platformx.onlinestatus = false
                platformy.onlinestatus = false
                platformz.onlinestatus = false
                platformh.onlinestatus = false
            }
            // 方法类型检查
            else if(params.method === "axisStatusUpdate") {
                console.log("Axis:", params.axis)
                console.log("Position:", params.position)
                console.log("Error code:", params.error)
            
                if(params.axis === 0)
                {
                    platformx.axispos = params.position
                    platformx.errorstatus = params.error
                }
                if(params.axis === 1)
                {
                    platformy.axispos = params.position
                    platformy.errorstatus = params.error
                }
                if(params.axis === 2)
                {
                    platformz.axispos = params.position
                    platformz.errorstatus = params.error
                }
                if(params.axis === 3)
                {
                    platformh.axispos = params.position
                    platformh.errorstatus = params.error
                }
            }
            else if (params.method === "shakingtable.voltage")
            {
                if (params.chl === 0)
                {
                    stxVoltage.text = params.voltage.toFixed(2)
                }
                else if (params.chl === 1)
                {
                    styVoltage.text = params.voltage.toFixed(2)
                }
                else if (params.chl === 2)
                {
                    stzVoltage.text = params.voltage.toFixed(2)
                }
            }
            else if (params.method === "shakingtable.position")
            {
                if (params.chl === 0)
                {
                    stxPosition.text = params.position.toFixed(2)
                }
                else if (params.chl === 1)
                {
                    styPosition.text = params.position.toFixed(2)
                }
                else if (params.chl === 2)
                {
                    stzPosition.text = params.position.toFixed(2)
                }
            }
            else if (params.method === "servo.report")
            {
                console.log("Servo status report:", params)
                azimuthText.text = params.angleX.toFixed(2)
                pitchText.text = params.angleY.toFixed(2)

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

                statusText.text = params.statusCode.toInteger()
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
                    model: ["平行光管", "运动平台", "微振动台", "伺服转台"]
        
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
                            id: cardPageSwitch
                            title: "切换机构"
    
                            Column {
                                anchors.top: parent.top
                                anchors.topMargin: 70
                                anchors.left: parent.left
                                anchors.leftMargin: 0
                                padding: 10
                                spacing: 100

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
                                        Layout.preferredWidth: 120
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
                                        Layout.preferredWidth: 120
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
    
                            anchors.left: cardPage.right
                            anchors.leftMargin: 45

                            Column {
                                anchors.top: parent.top
                                anchors.topMargin: 55
                                anchors.fill: parent
                                padding: 25
                                spacing: 100
                                
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
                                        font.pixelSize: 18 
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    // 优化后的挡位显示
                                    Rectangle {
                                        Layout.preferredWidth: 120
                                        height: 40
                                        radius: 8
                                        border.color: "#3F51B5"
                                        border.width: 2
                                        color: "#E8EAF6"
                
                                        Text {
                                            id: filterGear
                                            anchors.centerIn: parent
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: "#1A237E"
                                        }
                                    }

                                    Label {
                                        text: "电机状态" 
                                        color: "#404040" 
                                        font.pixelSize: 18 
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    // 优化后的状态显示
                                    Rectangle {
                                        Layout.preferredWidth: 120
                                        height: 40
                                        radius: 8
                                        border.color: "#4CAF50"
                                        border.width: 2
                                        color: "#E8F5E9"
                
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
                            anchors.left: cardPage2.right
                            anchors.leftMargin: 45
                            title:"波片切换机构"
                            Column {
                                
                                anchors.top: parent.top
                                anchors.topMargin: 70
                                anchors.left: parent.left
                                anchors.leftMargin: 0
                                padding: 10
                                spacing: 100

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
                                        Layout.preferredWidth: 120
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
                                        Layout.preferredWidth: 120
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
                        columnSpacing: 12
                        width: 1620
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        LSControlPanel{
                            id: platformx
                            titleText: "支撑平台方位"
                            bridge: bridge
                            code: "platform.x"
                        }

                        LSControlPanel{
                            id: platformy
                            titleText: "支撑平台俯仰"
                            bridge: bridge
                            code: "platform.y"
                        }

                        LSControlPanel{
                            id: platformz
                            titleText: "支撑平台高低"
                            bridge: bridge
                            code: "platform.z"
                        }

                        LSControlPanel{
                            id: platformh
                            titleText: "升降台"
                            bridge: bridge
                            code: "platform.hight"
                        }
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
                        columnSpacing: 12
                        width: 1620
                        anchors.horizontalCenter: parent.horizontalCenter
                        //震动设置 x
                        CardPage {
                            title:"微振动台-方位"
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
                                            bridge.sendtoCpp({"method":"‌shakingtable.open","chl":"x","wave":waveCombox1.currentIndex,"peak":peakText1.text,"freq":freqText1.text,"offset":offsetText1.text})
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
                                    spacing: 15
                                    Layout.alignment: Qt.AlignHCenter
                                    Label {
                                        text: "电压" 
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
                                            id: stxVoltage
                                            anchors.centerIn: parent
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: "#1A237E"
                                        }
                                    }

                                    Label {
                                        text: "位移" 
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
                            title:"微振动台-俯仰"
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
                                            bridge.sendtoCpp({"method":"‌shakingtable.open","chl":"y","wave":waveCombox2.currentIndex,"peak":peakText2.text,"freq":freqText2.text,"offset":offsetText2.text})
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
                                    spacing: 15
                                    Layout.alignment: Qt.AlignHCenter
                                    Label {
                                        text: "电压" 
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
                                            id: styVoltage
                                            anchors.centerIn: parent
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: "#1A237E"
                                        }
                                    }

                                    Label {
                                        text: "位移" 
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
                // 主布局
                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 25
                    contentWidth: dashboard3.width
                    contentHeight: dashboard3.height
                    GridLayout {
                        id: dashboard3
                        columns: 3
                        rowSpacing: 25
                        columnSpacing: 12
                        width: 1620
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        //双轴转台
                        CardPage {
                            title:"双轴转台"
                            width: 800
                            height: 500
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
                                        text: "位移模式"
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
                                            text: "0.00°"
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
                                        text: "方位:"
                                        color: "#333333"
                                        font.pixelSize: 20
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    TextField {
                                        id: xPosInput
                                        Layout.fillWidth: true
                                        placeholderText: "0.0"
                                        color: "#333333"
                                        font.pixelSize: 24
                                        validator: DoubleValidator { bottom: -360; top: 360 }
                                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                                        background: Rectangle {
                                            color: "#f8f8f8"
                                            radius: 4
                                            border.color: xVelInput.activeFocus ? "#4a90e2" : "#cccccc"
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
                                            bridge.sendtoCpp({"method":"servo.setposx","value":xPosInput.text})
                                        }
                                    }

                                    Label {
                                        text: "俯仰:"
                                        color: "#333333"
                                        font.pixelSize: 20
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    TextField {
                                        id: yPosInput
                                        Layout.fillWidth: true
                                        placeholderText: "0.0"
                                        color: "#333333"
                                        font.pixelSize: 24
                                        validator: DoubleValidator { bottom: -360; top: 360 }
                                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                                        background: Rectangle {
                                            color: "#f8f8f8"
                                            radius: 4
                                            border.color: yVelInput.activeFocus ? "#4a90e2" : "#cccccc"
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
                                            bridge.sendtoCpp({"method":"servo.setposy","value":yPosInput.text})
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
                                        placeholderText: "0.0"
                                        color: "#333333"
                                        font.pixelSize: 24
                                        validator: DoubleValidator { bottom: -360; top: 360 }
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
                                        placeholderText: "0.0"
                                        color: "#333333"
                                        font.pixelSize: 24
                                        validator: DoubleValidator { bottom: -360; top: 360 }
                                        inputMethodHints: Qt.ImhFormattedNumbersOnly
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
                                            text: "0.00°"
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
                                            text: "0.00°"
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
                                            text: "正常"
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
}
