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
            else if (params.method === "filterwheel.online")
            {
                cardPageFilter.isOnline = true
            }
            else if (params.method === "filterwheel.offline")
            {
                cardPageFilter.isOnline = false
            }
            else if (params.method === "waveplate.online")
            {
                cardPageWaveplate.isOnline = true
            }
            else if (params.method === "waveplate.offline")
            {
                cardPageWaveplate.isOnline = false
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
                stxVoltage.text = params.x.toFixed(2)
                styVoltage.text = params.y.toFixed(2)
                stzVoltage.text = params.z.toFixed(2)
            }
            else if (params.method === "shakingtable.position")
            {
                stxPosition.text = params.x.toFixed(2)
                styPosition.text = params.y.toFixed(2)
                stzPosition.text = params.z.toFixed(2)
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
                                            anchors.centerIn: parent
                                            text: "0.00 mm"
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
                                            bridge.sendtoCpp({"method":"filterwheel.setgear‌","value": model.currentIndex})
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
                                            anchors.centerIn: parent
                                            text: "1档"
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
                                    spacing: 100
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
                                        Layout.preferredWidth: 120
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
                        columnSpacing: 25
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

                         //震动设置
                        CardPage {
                            title:"微振动台-横滚"
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
                                        id: waveCombox3
                                        Layout.preferredWidth: 180  // 使用Layout.preferredWidth代替width
                                        Layout.preferredHeight: 50  // 使用Layout.preferredHeight代替height

                                        font.pixelSize: 22
                                    
                                        editable: false
                                        model: ListModel {
                                            id: model3
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
                                        id: peakText3
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
                                        id: freqText3
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
                                        id: offsetText3
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
                                            bridge.sendtoCpp({"method":"‌shakingtable.open","chl":"z","wave":waveCombox3.currentIndex,"peak":peakText3.text,"freq":freqText3.text,"offset":offsetText3.text})
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
                                            bridge.sendtoCpp({"method":"‌shakingtable.close","chl":"z"})
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
                                            id: stzVoltage
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
                                            id: stzPosition
                                            anchors.centerIn: parent
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
