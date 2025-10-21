import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import com.company.bridge 1.0

CardPage {
    property var titleText: ""
    property var bridge

    property var azimuthPos        // 方位位置反馈
    property var azimuthError      // 方位错误状态
    property var azimuthStatus     // 方位运动状态

    property var elevationPos      // 俯仰位置反馈
    property var elevationError    // 俯仰错误状态
    property var elevationStatus   // 俯仰运动状态    

    property var smallLiftPos      // 小升降位置反馈
    property var smallLiftError    // 小升降错误状态
    property var smallLiftStatus   // 小升降运动状态

    property var largeLiftPos      // 大升降位置反馈
    property var largeLiftError    // 大升降错误状态
    property var largeLiftStatus   // 大升降运动状态

    property bool platformxEnabled: false  // false = 失能, true = 使能
    property bool platformyEnabled: false  // false = 失能, true = 使能
    property bool platformzEnabled: false  // false = 失能, true = 使能
    property bool platformhEnabled: false  // false = 失能, true = 使能

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
        
        RowLayout {
            spacing: 10
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                id: groupBox
                width: 500
                height: 300
                radius: 12
                border.color: "#666666"
                border.width: 2
                color: "transparent"
            
                // 标题
                Rectangle {
                    id: titleRect
                    color: "#f5f5f5"
                    anchors.left: parent.left
                    anchors.leftMargin: 30
                    anchors.top: parent.top
                    anchors.topMargin: -10
                    z: 1
                    height: titleLabel.height + 4
                    width: titleLabel.width + 10

                    Text {
                        id: titleLabel
                        text: "控制操作"
                        font.pixelSize: 20
                        color: "#333333"
                        anchors.centerIn: parent
                    }
                }

                // 按钮整体布局：竖排
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20

                    // 第一行：方位
                    RowLayout {
                        spacing: 10
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            text: "方位"
                            font.pixelSize: 20
                            color: "#333333"
                            Layout.alignment: Qt.AlignVCenter
                            Layout.minimumWidth: 80 // 保证文本区域宽度
                        }

                        FluButton {
                            id: enableBtn
                            text: "使能"
                            font.family: "SimSun"
                            font.pixelSize: 20
                            Layout.minimumWidth: 120
                            Layout.minimumHeight: 45
                            Layout.preferredWidth: 120

                            // 不用 background，而是内部覆盖层
                            Item {
                                anchors.fill: parent
                                Rectangle {
                                    anchors.fill: parent
                                    color: platformyEnabled ? "#4a90e2" : "transparent" // 选中才显示
                                    radius: 8
                                }
                            }

                            onClicked: {
                                platformyEnabled = true
                                bridge.sendtoCpp({"method": "supportplatform.enable", "target": "platform.y"});
                            }
                        }

                        FluButton {
                            id: disableBtn
                            text: "失能"
                            font.family: "SimSun"
                            font.pixelSize: 20
                            Layout.minimumWidth: 120
                            Layout.minimumHeight: 45
                            Layout.preferredWidth: 120

                            onClicked: {
                                platformyEnabled = false
                                bridge.sendtoCpp({"method": "supportplatform.unable", "target": "platform.y"});
                            }
                        }

                        FluButton {
                            text: "停止"
                            font.family: "SimSun"; font.pixelSize: 20
                            onClicked: bridge.sendtoCpp({"method": "supportplatform.stop","target":"platform.y"})
                            Layout.minimumWidth: 120
                            Layout.minimumHeight: 45
                            Layout.preferredWidth: 120
                        }
                    }

                    // 第二行：俯仰
                    RowLayout {
                        spacing: 10

                        Text {
                            text: "俯仰"
                            font.pixelSize: 20
                            color: "#333333"
                            Layout.alignment: Qt.AlignVCenter
                            Layout.minimumWidth: 80 // 保证文本区域宽度
                        }

                         // 使能按钮
                        FluButton {
                            text: "使能"
                            font.family: "SimSun"
                            font.pixelSize: 20
                            Layout.minimumWidth: 120
                            Layout.minimumHeight: 45
                            Layout.preferredWidth: 120

                            // 内部覆盖层，高亮显示
                            Item {
                                anchors.fill: parent
                                Rectangle {
                                    anchors.fill: parent
                                    color: platformxEnabled ? "#4a90e2" : "transparent" // 选中才显示
                                    radius: 8
                                }
                            }

                            onClicked: {
                                platformxEnabled = true
                                bridge.sendtoCpp({"method": "supportplatform.enable", "target": "platform.x"});
                            }
                        }

                        // 失能按钮
                        FluButton {
                            text: "失能"
                            font.family: "SimSun"
                            font.pixelSize: 20
                            Layout.minimumWidth: 120
                            Layout.minimumHeight: 45
                            Layout.preferredWidth: 120
                            onClicked: {
                                platformxEnabled = false
                                bridge.sendtoCpp({"method": "supportplatform.unable", "target": "platform.x"});
                            }
                        }

                        FluButton {
                            text: "停止"
                            font.family: "SimSun"; font.pixelSize: 20
                            onClicked: bridge.sendtoCpp({"method": "supportplatform.stop","target":"platform.x"})
                            Layout.minimumWidth: 120 // 统一按钮最小宽度
                            Layout.minimumHeight: 45 // 统一按钮最小高度
                            Layout.preferredWidth: 120 // 保证基础宽度
                        }
                    }

                    // 第三行：通用控制
                    RowLayout {
                        spacing: 10

                        Text {
                            text: "小升降台"
                            font.pixelSize: 20
                            color: "#333333"
                            Layout.alignment: Qt.AlignVCenter
                            Layout.minimumWidth: 80 // 保证文本区域宽度
                        }

                        // 使能按钮
                        FluButton {
                            text: "使能"
                            font.family: "SimSun"
                            font.pixelSize: 20
                            Layout.minimumWidth: 120
                            Layout.minimumHeight: 45
                            Layout.preferredWidth: 120

                            // 内部覆盖层，高亮显示
                            Item {
                                anchors.fill: parent
                                Rectangle {
                                    anchors.fill: parent
                                    color: platformzEnabled ? "#4a90e2" : "transparent" // 选中才显示
                                    radius: 8
                                }
                            }

                            onClicked: {
                                platformzEnabled = true
                                bridge.sendtoCpp({"method": "supportplatform.enable", "target": "platform.z"});
                            }
                        }

                        // 失能按钮
                        FluButton {
                            text: "失能"
                            font.family: "SimSun"
                            font.pixelSize: 20
                            Layout.minimumWidth: 120
                            Layout.minimumHeight: 45
                            Layout.preferredWidth: 120

                            onClicked: {
                                platformzEnabled = false
                                bridge.sendtoCpp({"method": "supportplatform.unable", "target": "platform.z"});
                            }
                        }
                        FluButton {
                            text: "停止"
                            font.family: "SimSun"; font.pixelSize: 20
                            onClicked: bridge.sendtoCpp({"method": "supportplatform.stop","target":"platform.z"})
                            Layout.minimumWidth: 120 // 统一按钮最小宽度
                            Layout.minimumHeight: 45 // 统一按钮最小高度
                            Layout.preferredWidth: 120 // 保证基础宽度
                        }
                    }

                    // 第三行：通用控制
                    RowLayout {
                        spacing: 10

                        Text {
                            text: "大升降台"
                            font.pixelSize: 20
                            color: "#333333"
                            Layout.alignment: Qt.AlignVCenter
                            Layout.minimumWidth: 80 // 保证文本区域宽度
                        }

                        // 使能按钮
                        FluButton {
                            text: "使能"
                            font.family: "SimSun"
                            font.pixelSize: 20
                            Layout.minimumWidth: 120
                            Layout.minimumHeight: 45
                            Layout.preferredWidth: 120

                            // 内部覆盖层，高亮显示
                            Item {
                                anchors.fill: parent
                                Rectangle {
                                    anchors.fill: parent
                                    color: platformhEnabled ? "#4a90e2" : "transparent" // 选中才显示
                                    radius: 8
                                }
                            }

                            onClicked: {
                                platformhEnabled = true
                                bridge.sendtoCpp({"method": "supportplatform.enable", "target": "platform.height"});
                            }
                        }

                        // 失能按钮
                        FluButton {
                            text: "失能"
                            font.family: "SimSun"
                            font.pixelSize: 20
                            Layout.minimumWidth: 120
                            Layout.minimumHeight: 45
                            Layout.preferredWidth: 120

                            onClicked: {
                                platformhEnabled = false
                                bridge.sendtoCpp({"method": "supportplatform.unable", "target": "platform.height"});
                            }
                        }
                        FluButton {
                            text: "停止"
                            font.family: "SimSun"; font.pixelSize: 20
                            onClicked: bridge.sendtoCpp({"method": "supportplatform.stop","target":"platform.height"})
                            Layout.minimumWidth: 120 // 统一按钮最小宽度
                            Layout.minimumHeight: 45 // 统一按钮最小高度
                            Layout.preferredWidth: 120 // 保证基础宽度
                        }
                    }
                }
            }
        
            Rectangle {
                id: groupBox2
                width: 500
                height: 300
                radius: 12
                border.color: "#666666"
                border.width: 2
                color: "transparent"
            
                // 标题
                Rectangle {
                    id: titleRect2
                    color: "#f5f5f5"
                    anchors.left: parent.left
                    anchors.leftMargin: 30
                    anchors.top: parent.top
                    anchors.topMargin: -10
                    z: 1
                    height: titleLabel2.height + 4
                    width: titleLabel2.width + 10

                    Text {
                        id: titleLabel2
                        text: "定位模式"
                        font.pixelSize: 20
                        color: "#333333"
                        anchors.centerIn: parent
                    }
                }

                // 按钮整体布局：竖排
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20

                    // 第一行：方位
                    RowLayout {
                        spacing: 10
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            text: "方位（˚）  "
                            font.pixelSize: 20
                            color: "#333333"
                            Layout.alignment: Qt.AlignVCenter
                            Layout.minimumWidth: 80 // 保证文本区域宽度
                        }

                        // 输入框1
                        TextField {
                            id: angleInputAzimuth
                            placeholderText: "-90.000～90.000"
                            font.pixelSize: 13
                            Layout.minimumWidth: 120
                            Layout.minimumHeight: 45
                            Layout.preferredWidth: 120
                            validator: DoubleValidator { bottom: -90; top: 90; decimals: 3 } // 范围可改
                            
                            // 按回车（Return）时触发（最可靠）
                            Keys.onReturnPressed: {
                                validateAndFormat()
                            }

                            // TextField 在某些版本/平台会有 accepted 信号（回车确认）
                            onAccepted: {
                                validateAndFormat()
                            }

                            // 失去焦点时触发（用户点击别处或切换控件）
                            onActiveFocusChanged: {
                                if (!activeFocus) {
                                    validateAndFormat()
                                }
                            }

                            // 仍保留 editingFinished（兼容）
                            onEditingFinished: {
                                validateAndFormat()
                            }

                            // 验证并格式化的统一函数（不要在用户编辑过程中被调用）
                            function validateAndFormat() {
                                // 允许空（视场景而定）
                                if (text === "" || text === "-" || text === "." || text === "-.") {
                                    // 中间状态/用户正在输入，保持不变（或你可以清空）
                                    return
                                }

                                var v = Number(text)
                                if (isNaN(v)) {
                                    return
                                }

                                // 限制范围并格式化为 3 位小数（根据你的 validator）
                                if (v > 90) v = 90
                                if (v < -90) v = -90
                                text = v.toFixed(3)
                            }


                            background: Rectangle {
                                radius: 4                          // 圆角
                                border.width: 2
                                border.color: angleInputAzimuth.activeFocus ? "#448aff" : "#cccccc"
                                color: "#ffffff"                   // 背景色
                            }
                        }

                        // 输入框2
                        TextField {
                            id: speedInputAzimuth
                            placeholderText: "0.001～3.000"
                            font.pixelSize: 13
                            Layout.minimumWidth: 120
                            Layout.minimumHeight: 45
                            Layout.preferredWidth: 120
                            validator: DoubleValidator { bottom: 0.001; top: 3.000; decimals: 3 } // 范围可改

                            // 按下回车
                            Keys.onReturnPressed: validateAndFormat()
                            // 某些平台 accepted 信号（回车确认）
                            onAccepted: validateAndFormat()
                            // 失去焦点时
                            onActiveFocusChanged: if (!activeFocus) validateAndFormat()
                            // 兼容 editingFinished
                            onEditingFinished: validateAndFormat()

                            function validateAndFormat() {
                                if (text === "" || text === "." || text === "0." || text === "-") {
                                    // 允许中间状态，不强制修改
                                    return
                                }
                                var v = parseFloat(text)
                                if (isNaN(v)) return

                                if (v > 3.0) v = 3.0
                                if (v < 0.001) v = 0.001

                                text = v.toFixed(3)   // 格式化三位小数
                            }

                            background: Rectangle {
                                radius: 4                          // 圆角
                                border.width: 2
                                border.color: speedInputAzimuth.activeFocus ? "#448aff" : "#cccccc"
                                color: "#ffffff"                   // 背景色
                            }
                        }

                        // 按钮
                        FluButton {
                            text: "下发"
                            font.family: "SimSun"
                            font.pixelSize: 20
                            onClicked: {
                                if (!angleInputAzimuth.text || !speedInputAzimuth.text) {
                                    return
                                }
                                bridge.sendtoCpp({
                                    "method": "supportplatform.position",
                                    "target": "platform.y",
                                    "position": angleInputAzimuth.text,
                                    "speed": speedInputAzimuth.text
                                })
                            }
                            Layout.minimumWidth: 80
                            Layout.minimumHeight: 45
                            Layout.preferredWidth: 80
                        }
                    }


                    // 第二行：俯仰
                    RowLayout {
                        spacing: 10

                        Text {
                            text: "俯仰（˚）  "
                            font.pixelSize: 20
                            color: "#333333"
                            Layout.alignment: Qt.AlignVCenter
                            Layout.minimumWidth: 80 // 保证文本区域宽度
                        }

                        // 输入框1
                        TextField {
                            id: angleInputPitch
                            placeholderText: "-15.000～15.000"
                            font.pixelSize: 13
                            Layout.minimumWidth: 120
                            Layout.minimumHeight: 45
                            Layout.preferredWidth: 120
                            validator: DoubleValidator { bottom: -15; top: 15; decimals: 3 } // 范围可改

                            // 按下回车
                            Keys.onReturnPressed: validateAndFormat()
                            // 某些平台 accepted 信号（回车确认）
                            onAccepted: validateAndFormat()
                            // 失去焦点时
                            onActiveFocusChanged: if (!activeFocus) validateAndFormat()
                            // 兼容 editingFinished
                            onEditingFinished: validateAndFormat()

                            function validateAndFormat() {
                                // 允许中间输入状态，不强制修改
                                if (text === "" || text === "." || text === "0." || text === "-") return

                                var v = parseFloat(text)
                                if (isNaN(v)) return

                                // 限制范围
                                if (v > 15.0) v = 15.0
                                if (v < -15.0) v = -15.0

                                // 格式化为三位小数
                                text = v.toFixed(3)
                            }

                            background: Rectangle {
                                radius: 4                          // 圆角
                                border.width: 2
                                border.color: angleInputPitch.activeFocus ? "#448aff" : "#cccccc"
                                color: "#ffffff"                   // 背景色
                            }
                        }

                        // 输入框2
                        TextField {
                            id: speedInputPitch
                            placeholderText: "0.001～3.000"
                            font.pixelSize: 14
                            Layout.minimumWidth: 120
                            Layout.minimumHeight: 45
                            Layout.preferredWidth: 120
                            validator: DoubleValidator { bottom: 0.001; top: 3.000; decimals: 3 } // 范围可改
                            
                            // 按下回车
                            Keys.onReturnPressed: validateAndFormat()
                            // 某些平台 accepted 信号（回车确认）
                            onAccepted: validateAndFormat()
                            // 失去焦点时
                            onActiveFocusChanged: if (!activeFocus) validateAndFormat()
                            // 兼容 editingFinished
                            onEditingFinished: validateAndFormat()

                            function validateAndFormat() {
                                if (text === "" || text === "." || text === "0." || text === "-") {
                                    // 允许中间状态，不强制修改
                                    return
                                }
                                var v = parseFloat(text)
                                if (isNaN(v)) return

                                if (v > 3.0) v = 3.0
                                if (v < 0.001) v = 0.001

                                text = v.toFixed(3)   // 格式化三位小数
                            }

                            background: Rectangle {
                                radius: 4                          // 圆角
                                border.width: 2
                                border.color: speedInputPitch.activeFocus ? "#448aff" : "#cccccc"
                                color: "#ffffff"                   // 背景色
                            }
                        }

                        FluButton {
                            text: "下发"
                            font.family: "SimSun"; font.pixelSize: 20
                            onClicked: {
                                if (!angleInputPitch.text || !speedInputPitch.text) {
                                    return
                                }
                                bridge.sendtoCpp({
                                    "method": "supportplatform.position",
                                    "target": "platform.x",
                                    "position": angleInputPitch.text,
                                    "speed": speedInputPitch.text
                                })
                            }
                            Layout.minimumWidth: 80 // 统一按钮最小宽度
                            Layout.minimumHeight: 45 // 统一按钮最小高度
                            Layout.preferredWidth: 80 // 保证基础宽度
                        }
                    }

                    // 第三行：通用控制
                    RowLayout {
                        spacing: 10

                        Text {
                            text: "小升降（mm）"
                            font.pixelSize: 20
                            color: "#333333"
                            Layout.alignment: Qt.AlignVCenter
                            Layout.minimumWidth: 80 // 保证文本区域宽度
                        }

                        // 输入框1
                        TextField {
                            id: heightInputElevation
                            placeholderText: "0.00～300.00"
                            font.pixelSize: 14
                            Layout.minimumWidth: 120
                            Layout.minimumHeight: 45
                            Layout.preferredWidth: 120
                            validator: DoubleValidator { bottom: 0.01; top: 300.00; decimals: 2 } // 范围可改
                            
                            // 按下回车
                            Keys.onReturnPressed: validateAndFormat()
                            // accepted 信号（回车确认）
                            onAccepted: validateAndFormat()
                            // 失去焦点时
                            onActiveFocusChanged: if (!activeFocus) validateAndFormat()
                            // 兼容 editingFinished
                            onEditingFinished: validateAndFormat()

                            function validateAndFormat() {
                                // 允许中间状态，不打断用户输入
                                if (text === "" || text === "." || text === "0." || text === "-") return

                                var v = parseFloat(text)
                                if (isNaN(v)) return

                                // 限制范围
                                if (v > 300.0) v = 300.0
                                if (v < 0.01) v = 0.01

                                // 格式化为两位小数
                                text = v.toFixed(2)
                            }


                            background: Rectangle {
                                radius: 4                          // 圆角
                                border.width: 2
                                border.color: heightInputElevation.activeFocus ? "#448aff" : "#cccccc"
                                color: "#ffffff"                   // 背景色
                            }
                        }

                        // 输入框2
                        TextField {
                            id: speedInputElevation
                            placeholderText: "0.01～3.00"
                            font.pixelSize: 14
                            Layout.minimumWidth: 120
                            Layout.minimumHeight: 45
                            Layout.preferredWidth: 120
                            validator: DoubleValidator { bottom: 0.01; top: 3.00; decimals: 2 } // 范围可改

                            // 按下回车
                            Keys.onReturnPressed: validateAndFormat()
                            // accepted 信号（回车确认）
                            onAccepted: validateAndFormat()
                            // 失去焦点时
                            onActiveFocusChanged: if (!activeFocus) validateAndFormat()
                            // 兼容 editingFinished
                            onEditingFinished: validateAndFormat()

                            function validateAndFormat() {
                                // 允许中间输入状态，不强制修改
                                if (text === "" || text === "." || text === "0." || text === "-") return

                                var v = parseFloat(text)
                                if (isNaN(v)) return

                                // 限制范围
                                if (v > 3.00) v = 3.00
                                if (v < 0.01) v = 0.01

                                // 格式化为两位小数
                                text = v.toFixed(2)
                            }

                            background: Rectangle {
                                radius: 4                          // 圆角
                                border.width: 2
                                border.color: speedInputElevation.activeFocus ? "#448aff" : "#cccccc"
                                color: "#ffffff"                   // 背景色
                            }
                        }

                        FluButton {
                            text: "下发"
                            font.family: "SimSun"; font.pixelSize: 20
                            onClicked: {
                                if (!heightInputElevation.text || !speedInputElevation.text) {
                                    return
                                }
                                bridge.sendtoCpp({
                                    "method": "supportplatform.position",
                                    "target": "platform.z",
                                    "position": heightInputElevation.text,
                                    "speed": speedInputElevation.text
                                })
                            }
                            Layout.minimumWidth: 80 // 统一按钮最小宽度
                            Layout.minimumHeight: 45 // 统一按钮最小高度
                            Layout.preferredWidth: 80 // 保证基础宽度
                        }
                    }

                    // 第三行：通用控制
                    RowLayout {
                        spacing: 10

                        Text {
                            text: "大升降（mm）"
                            font.pixelSize: 20
                            color: "#333333"
                            Layout.alignment: Qt.AlignVCenter
                            Layout.minimumWidth: 80 // 保证文本区域宽度
                        }

                        // 输入框1
                        TextField {
                            id: heightInputBigElevation
                            placeholderText: "1400～3900"
                            font.pixelSize: 14
                            Layout.minimumWidth: 120
                            Layout.minimumHeight: 45
                            Layout.preferredWidth: 120
                            validator: DoubleValidator { bottom: 1400; top: 3900; decimals: 2 } // 范围可改

                            // 按下回车
                            Keys.onReturnPressed: validateAndFormat()
                            // accepted 信号（回车确认）
                            onAccepted: validateAndFormat()
                            // 失去焦点时
                            onActiveFocusChanged: if (!activeFocus) validateAndFormat()
                            // 兼容 editingFinished
                            onEditingFinished: validateAndFormat()

                            function validateAndFormat() {
                                // 允许中间输入状态，不打断用户输入
                                if (text === "" || text === "." || text === "0." || text === "-") return

                                var v = parseFloat(text)
                                if (isNaN(v)) return

                                // 限制范围
                                if (v > 3900.0) v = 3900.0
                                if (v < 1400.0) v = 1400.0

                                // 格式化为两位小数
                                text = v.toFixed(2)
                            }

                            background: Rectangle {
                                radius: 4                          // 圆角
                                border.width: 2
                                border.color: heightInputBigElevation.activeFocus ? "#448aff" : "#cccccc"
                                color: "#ffffff"                   // 背景色
                            }
                        }

                        // 输入框2
                        TextField {
                            id: speedInputBigElevation
                            placeholderText: "0.01～3.00"
                            font.pixelSize: 14
                            Layout.minimumWidth: 120
                            Layout.minimumHeight: 45
                            Layout.preferredWidth: 120
                            validator: DoubleValidator { bottom: 0.01; top: 3.00; decimals: 2 } // 范围可改

                            // 按下回车
                            Keys.onReturnPressed: validateAndFormat()
                            // accepted 信号（回车确认）
                            onAccepted: validateAndFormat()
                            // 失去焦点时
                            onActiveFocusChanged: if (!activeFocus) validateAndFormat()
                            // 兼容 editingFinished
                            onEditingFinished: validateAndFormat()

                            function validateAndFormat() {
                                // 允许中间状态，不强制修改
                                if (text === "" || text === "." || text === "0." || text === "-") return

                                var v = parseFloat(text)
                                if (isNaN(v)) return

                                // 限制范围
                                if (v > 3.0) v = 3.0
                                if (v < 0.01) v = 0.01

                                // 格式化两位小数
                                text = v.toFixed(2)
                            }

                            background: Rectangle {
                                radius: 4                          // 圆角
                                border.width: 2
                                border.color: speedInputBigElevation.activeFocus ? "#448aff" : "#cccccc"
                                color: "#ffffff"                   // 背景色
                            }
                        }

                        FluButton {
                            text: "下发"
                            font.family: "SimSun"; font.pixelSize: 20
                            onClicked: {
                                if (!heightInputBigElevation.text || !speedInputBigElevation.text) {
                                    return
                                }
                                bridge.sendtoCpp({
                                    "method": "supportplatform.position",
                                    "target": "platform.height",
                                    "position": heightInputBigElevation.text,
                                    "speed": speedInputBigElevation.text
                                })
                            }
                            Layout.minimumWidth: 80 // 统一按钮最小宽度
                            Layout.minimumHeight: 45 // 统一按钮最小高度
                            Layout.preferredWidth: 80 // 保证基础宽度
                        }
                    }
                }
            }
        }

        RowLayout {
            spacing: 10
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                id: groupBox1
                width: 500
                height: 360
                radius: 12
                border.color: "#666666"
                border.width: 2
                color: "transparent"

                // 标题
                Rectangle {
                    id: titleRect1
                    color: "#f5f5f5"
                    anchors.left: parent.left
                    anchors.leftMargin: 30
                    anchors.top: parent.top
                    anchors.topMargin: -10
                    z: 1
                    height: titleLabel.height + 4
                    width: titleLabel.width + 10

                    Text {
                        id: titleLabel1
                        text: "角度控制"
                        font.pixelSize: 20
                        color: "#333333"
                        anchors.centerIn: parent
                    }
                }
            
                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.top: parent.top
                    anchors.topMargin: 30
                    spacing: 15
                    
                    Text {
                        text: "方位(˚/s)"
                        font.pixelSize: 20
                        color: "#333333"
                        Layout.alignment: Qt.AlignVCenter
                        Layout.minimumWidth: 80 // 保证文本区域宽度
                    }

                    SpinBox {
                        id: control
                        from: 0
                        to: 1000
                        stepSize: 10
                        value: 100
                        editable: true
    
                        // 真实值，外部用这个取 double
                        property double realValue: value / 100.0
    
                        // 格式化显示（两位小数）
                        textFromValue: function(value, locale) {
                            return Number(value / 100.0).toFixed(2)
                        }
    
                        // 输入时转换回整数（放大100倍存储）
                        valueFromText: function(text, locale) {
                            return Math.round(parseFloat(text) * 100)
                        }
    
                        // 输入框
                        contentItem: TextInput {
                            anchors.fill: parent
                            anchors.rightMargin: control.width * 0.3 + 1 // 留出按钮区域和分隔线宽度
                            anchors.leftMargin: 5 // 添加左边距
        
                            text: control.textFromValue(control.value, control.locale)
                            font.pixelSize: 22
                            color: "#222"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            validator: control.validator
                            selectByMouse: true
                        }
    
                        // 向上按钮
                        up.indicator: Rectangle {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            width: parent.width * 0.3
                            height: parent.height / 2
                            color: control.up.pressed ? "#d0d0d0" : "transparent"
        
                            Image {
                                anchors.centerIn: parent
                                source: "image/up.png"
                                sourceSize.width: 16
                                sourceSize.height: 16
                            }
                        }
    
                        // 向下按钮
                        down.indicator: Rectangle {
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            width: parent.width * 0.3
                            height: parent.height / 2
                            color: control.down.pressed ? "#d0d0d0" : "transparent"
        
                            Image {
                                anchors.centerIn: parent
                                source: "image/down.png"
                                sourceSize.width: 16
                                sourceSize.height: 16
                            }
                        }
    
                        // 外框
                        background: Rectangle {
                            implicitWidth: 110
                            implicitHeight: 40
                            radius: 6
                            border.color: "#aaa"
                            border.width: 1
                            color: "#fafafa"
        
                            Rectangle {   // 输入框和按钮分隔线
                                anchors.right: parent.right
                                anchors.rightMargin: parent.width * 0.3
                                width: 1
                                height: parent.height
                                color: "#ddd"
                            }
                        }
    
                        // 添加一个透明的鼠标区域覆盖整个SpinBox，用于处理文本选择
                        MouseArea {
                            anchors.fill: parent
                            anchors.rightMargin: parent.width * 0.3 // 排除按钮区域
                            cursorShape: Qt.IBeamCursor
                            acceptedButtons: Qt.LeftButton
                            onPressed: {
                                // 将点击事件传递给文本输入
                                control.contentItem.forceActiveFocus()
                                mouse.accepted = false // 让事件继续传播
                            }
                        }
                    }

                    Text {
                        text: "俯仰(˚/s)"
                        font.pixelSize: 20
                        color: "#333333"
                        Layout.alignment: Qt.AlignVCenter
                        Layout.minimumWidth: 80 // 保证文本区域宽度
                    }                    

                    SpinBox {
                        id: control2
                        from: 0
                        to: 1000          // 实际表示 0.00 ~ 10.00
                        stepSize: 10       // 实际表示 0.01
                        value: 100        // 初始值 1.00
                        editable: true

                        // 真实值，外部用这个取 double
                        property double realValue: value / 100.0

                        // 格式化显示（两位小数）
                        textFromValue: function(value, locale) {
                            return Number(value / 100.0).toFixed(2)
                        }

                        // 输入时转换回整数（放大100倍存储）
                        valueFromText: function(text, locale) {
                            return Math.round(parseFloat(text) * 100)
                        }

                        // 输入框 - 修改后的部分
                        contentItem: TextInput {
                            anchors.fill: parent
                            anchors.rightMargin: control2.width * 0.3 + 1 // 留出按钮区域和分隔线宽度
                            anchors.leftMargin: 5 // 添加左边距
        
                            text: control2.textFromValue(control2.value, control2.locale)
                            font.pixelSize: 22
                            color: "#222"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            validator: control2.validator
                            selectByMouse: true
                        }

                        // 向上按钮
                        up.indicator: Rectangle {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            width: parent.width * 0.3
                            height: parent.height / 2
                            color: control2.up.pressed ? "#d0d0d0" : "transparent"

                            Image {
                                anchors.centerIn: parent
                                source: "image/up.png"
                                sourceSize.width: 16
                                sourceSize.height: 16
                            }
                        }

                        // 向下按钮
                        down.indicator: Rectangle {
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            width: parent.width * 0.3
                            height: parent.height / 2
                            color: control2.down.pressed ? "#d0d0d0" : "transparent"

                            Image {
                                anchors.centerIn: parent
                                source: "image/down.png"
                                sourceSize.width: 16
                                sourceSize.height: 16
                            }
                        }

                        // 外框
                        background: Rectangle {
                            implicitWidth: 110
                            implicitHeight: 40
                            radius: 6
                            border.color: "#aaa"
                            border.width: 1
                            color: "#fafafa"

                            Rectangle {   // 输入框和按钮分隔线
                                anchors.right: parent.right
                                anchors.rightMargin: parent.width * 0.3 // 调整分隔线位置
                                width: 1
                                height: parent.height
                                color: "#ddd"
                            }
                        }
    
                        // 添加一个透明的鼠标区域覆盖整个SpinBox，用于处理文本选择
                        MouseArea {
                            anchors.fill: parent
                            anchors.rightMargin: parent.width * 0.3 // 排除按钮区域
                            cursorShape: Qt.IBeamCursor
                            acceptedButtons: Qt.LeftButton
                            onPressed: {
                                // 将点击事件传递给文本输入
                                control2.contentItem.forceActiveFocus()
                                mouse.accepted = false // 让事件继续传播
                            }
                        }
                    }
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: 30
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    spacing: 15
                    ColumnLayout {
                        spacing: 40
                        anchors.top: parent.top
                        anchors.topMargin: 90
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        anchors.bottomMargin: 20
                        Layout.fillWidth: true
                        // 上按钮
                        RowLayout {
                            spacing: 15
                            Layout.alignment: Qt.AlignHCenter
                            // 上按钮
                            Button {
                                text: "↑"
                                Layout.preferredHeight: 80
                                Layout.preferredWidth: 120

                                onPressed: {
                                    bridge.sendtoCpp({"method": "supportplatform.forward", "speed": control2.realValue, "target": "platform.x"});
                                }
                                onReleased: {
                                    bridge.sendtoCpp({"method": "supportplatform.stop", "target": "platform.x"});
                                }

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
                            spacing: 40
                            Layout.alignment: Qt.AlignHCenter
                            Button {
                                text: "←"
                                Layout.preferredHeight: 80
                                Layout.preferredWidth: 120

                                onPressed: {
                                    bridge.sendtoCpp({"method": "supportplatform.backward", "speed": control.realValue, "target": "platform.y"});
                                }

                                onReleased: {
                                    bridge.sendtoCpp({"method": "supportplatform.stop", "target": "platform.y"});
                                }

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

                                onPressed: {
                                    bridge.sendtoCpp({"method": "supportplatform.backward", "speed": control2.realValue, "target": "platform.x"});
                                }

                                onReleased: {
                                    bridge.sendtoCpp({"method": "supportplatform.stop", "target": "platform.x"});
                                }

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

                                onPressed: {
                                    bridge.sendtoCpp({"method": "supportplatform.forward", "speed": control.realValue, "target": "platform.y"});
                                }

                                onReleased: {
                                    bridge.sendtoCpp({"method": "supportplatform.stop", "target": "platform.y"});
                                }

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
                    }

                }
            }

            Rectangle {
                id: groupBox3
                width: 500
                height: 360
                radius: 12
                border.color: "#666666"
                border.width: 2
                color: "transparent"

                // 标题
                Rectangle {
                    id: titleRect3
                    color: "#f5f5f5"
                    anchors.left: parent.left
                    anchors.leftMargin: 30
                    anchors.top: parent.top
                    anchors.topMargin: -10
                    z: 1
                    height: titleLabel3.height + 4
                    width: titleLabel3.width + 10

                    Text {
                        id: titleLabel3
                        text: "高度控制"
                        font.pixelSize: 20
                        color: "#333333"
                        anchors.centerIn: parent
                    }

                    

                    ColumnLayout {
                        spacing: 20
                        anchors.top: parent.top
                        anchors.topMargin: 30
                        anchors.left: parent.left
                        anchors.leftMargin: 50
                        anchors.rightMargin: 20
                        anchors.bottomMargin: 20
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        
                        Text {
                            text: "小升降台"
                            font.pixelSize: 20
                            color: "#333333"
                            horizontalAlignment: Text.AlignHCenter  // 水平居中
                            Layout.preferredWidth: 120
                        }

                        
                        // 上按钮
                        Button {
                            text: "↑"
                            Layout.preferredHeight: 80
                            Layout.preferredWidth: 120

                            onPressed: {
                                bridge.sendtoCpp({"method": "supportplatform.forward", "speed": smallElevationSpeed.realValue, "target": "platform.z"});
                            }

                            onReleased: {
                                bridge.sendtoCpp({"method": "supportplatform.stop", "target": "platform.z"});
                            }

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

                        Text {
                            text: "速度（mm/s）"
                            font.pixelSize: 16
                            color: "#333333"
                            horizontalAlignment: Text.AlignHCenter  // 水平居中
                            Layout.preferredWidth: 120
                        }

                        SpinBox {
                            id: smallElevationSpeed
                            from: 0
                            to: 300          // 实际表示 0.00 ~ 10.00
                            stepSize: 10       // 实际表示 0.01
                            value: 100        // 初始值 1.00
                            editable: true

                            property double realValue: value / 100.0

                            textFromValue: function(value, locale) {
                                return Number(value / 100.0).toFixed(2)
                            }

                            valueFromText: function(text, locale) {
                                return Math.round(parseFloat(text) * 100)
                            }

                            validator: DoubleValidator {
                                bottom: 0.01
                                top: 3.00 
                            }

                            contentItem: TextInput {
                                anchors.fill: parent
                                anchors.rightMargin: smallElevationSpeed.width * 0.3 + 1
                                anchors.leftMargin: 5
        
                                text: smallElevationSpeed.textFromValue(smallElevationSpeed.value, smallElevationSpeed.locale)
                                font.pixelSize: 20
                                color: "#222"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                validator: smallElevationSpeed.validator
                                selectByMouse: true

                                // 当输入完成后校验并格式化
                                Keys.onReturnPressed: validateAndFormat()
                                onEditingFinished: validateAndFormat()
                                onActiveFocusChanged: if (!activeFocus) validateAndFormat()

                                function validateAndFormat() {
                                    if (text === "" || text === "." || text === "0.") return

                                    var v = parseFloat(text)
                                    if (isNaN(v)) return

                                    // 限制范围
                                    if (v < 0.01) v = 0.01
                                    if (v > 3.0) v = 3.0

                                    // 更新 SpinBox 的 value（放大100倍存储）
                                    smallElevationSpeed.value = Math.round(v * 100)

                                    // 格式化显示两位小数
                                    text = v.toFixed(2)
                                }
                            }

                            // up/down按钮
                            up.indicator: Rectangle {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                width: parent.width * 0.3
                                height: parent.height / 2
                                color: smallElevationSpeed.up.pressed ? "#d0d0d0" : "transparent"

                                Image {
                                    anchors.centerIn: parent
                                    source: "image/up.png"
                                    sourceSize.width: 16
                                    sourceSize.height: 16
                                }
                            }

                            down.indicator: Rectangle {
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                width: parent.width * 0.3
                                height: parent.height / 2
                                color: smallElevationSpeed.down.pressed ? "#d0d0d0" : "transparent"

                                Image {
                                    anchors.centerIn: parent
                                    source: "image/down.png"
                                    sourceSize.width: 16
                                    sourceSize.height: 16
                                }
                            }

                            background: Rectangle {
                                implicitWidth: 120
                                implicitHeight: 40
                                radius: 6
                                border.color: "#aaa"
                                border.width: 1
                                color: "#fafafa"

                                Rectangle {   // 输入框和按钮分隔线
                                    anchors.right: parent.right
                                    anchors.rightMargin: parent.width * 0.3
                                    width: 1
                                    height: parent.height
                                    color: "#ddd"
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                anchors.rightMargin: parent.width * 0.3
                                cursorShape: Qt.IBeamCursor
                                acceptedButtons: Qt.LeftButton
                                onPressed: {
                                    smallElevationSpeed.contentItem.forceActiveFocus()
                                    mouse.accepted = false
                                }
                            }
                        }
                            
                        // 下按钮
                        Button {
                            text: "↓"
                            Layout.preferredHeight: 80
                            Layout.preferredWidth: 120

                            onPressed: {
                                bridge.sendtoCpp({"method": "supportplatform.backward", "speed": smallElevationSpeed.realValue, "target": "platform.z"});
                            }

                            onReleased: {
                                bridge.sendtoCpp({"method": "supportplatform.stop", "target": "platform.z"});
                            }

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

                    ColumnLayout {
                        spacing: 20
                        anchors.top: parent.top
                        anchors.topMargin: 30
                        anchors.left: parent.left
                        anchors.leftMargin: 270
                        anchors.rightMargin: 20
                        anchors.bottomMargin: 20
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        
                        Text {
                            text: "大升降台"
                            font.pixelSize: 20
                            color: "#333333"
                            horizontalAlignment: Text.AlignHCenter  // 水平居中
                            Layout.preferredWidth: 120
                        }

                        
                        // 上按钮
                        Button {
                            text: "↑"
                            Layout.preferredHeight: 80
                            Layout.preferredWidth: 120

                            onPressed: {
                                bridge.sendtoCpp({"method": "supportplatform.forward", "speed": bigElevationSpeed.realValue, "target": "platform.height"});
                            }

                            onReleased: {
                                bridge.sendtoCpp({"method": "supportplatform.stop", "target": "platform.height"});
                            }

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

                        Text {
                            text: "速度（mm/s）"
                            font.pixelSize: 16
                            color: "#333333"
                            horizontalAlignment: Text.AlignHCenter  // 水平居中
                            Layout.preferredWidth: 120
                        }

                        SpinBox {
                            id: bigElevationSpeed
                            from: 0
                            to: 300          // 实际表示 0.00 ~ 10.00
                            stepSize: 10       // 实际表示 0.01
                            value: 100        // 初始值 1.00
                            editable: true

                            // 真实值，外部用这个取 double
                            property double realValue: value / 100.0

                            // 格式化显示（两位小数）
                            textFromValue: function(value, locale) {
                                return Number(value / 100.0).toFixed(2)
                            }

                            // 输入时转换回整数（放大100倍存储）
                            valueFromText: function(text, locale) {
                                return Math.round(parseFloat(text) * 100)
                            }
                            
                            validator: DoubleValidator {
                                bottom: 0.01 
                                top: 3.00 
                            }

                            // 输入框 - 修改后的部分
                            contentItem: TextInput {
                                anchors.fill: parent
                                anchors.rightMargin: bigElevationSpeed.width * 0.3 + 1 // 留出按钮区域和分隔线宽度
                                anchors.leftMargin: 5 // 添加左边距
        
                                text: bigElevationSpeed.textFromValue(bigElevationSpeed.value, bigElevationSpeed.locale)
                                font.pixelSize: 20
                                color: "#222"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                validator: bigElevationSpeed.validator
                                selectByMouse: true
                                // 当输入完成后校验并格式化
                                Keys.onReturnPressed: validateAndFormat()
                                onEditingFinished: validateAndFormat()
                                onActiveFocusChanged: if (!activeFocus) validateAndFormat()

                                function validateAndFormat() {
                                    if (text === "" || text === "." || text === "0.") return

                                    var v = parseFloat(text)
                                    if (isNaN(v)) return

                                    // 限制范围
                                    if (v < 0.01) v = 0.01
                                    if (v > 3.0) v = 3.0

                                    // 更新 SpinBox 的 value（放大100倍存储）
                                    bigElevationSpeed.value = Math.round(v * 100)

                                    // 格式化显示两位小数
                                    text = v.toFixed(2)
                                }
                            }

                            // 向上按钮
                            up.indicator: Rectangle {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                width: parent.width * 0.3
                                height: parent.height / 2
                                color: bigElevationSpeed.up.pressed ? "#d0d0d0" : "transparent"

                                Image {
                                    anchors.centerIn: parent
                                    source: "image/up.png"
                                    sourceSize.width: 16
                                    sourceSize.height: 16
                                }
                            }

                            // 向下按钮
                            down.indicator: Rectangle {
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                width: parent.width * 0.3
                                height: parent.height / 2
                                color: bigElevationSpeed.down.pressed ? "#d0d0d0" : "transparent"

                                Image {
                                    anchors.centerIn: parent
                                    source: "image/down.png"
                                    sourceSize.width: 16
                                    sourceSize.height: 16
                                }
                            }

                            // 外框
                            background: Rectangle {
                                implicitWidth: 120
                                implicitHeight: 40
                                radius: 6
                                border.color: "#aaa"
                                border.width: 1
                                color: "#fafafa"

                                Rectangle {   // 输入框和按钮分隔线
                                    anchors.right: parent.right
                                    anchors.rightMargin: parent.width * 0.3 // 调整分隔线位置
                                    width: 1
                                    height: parent.height
                                    color: "#ddd"
                                }
                            }
    
                            // 添加一个透明的鼠标区域覆盖整个SpinBox，用于处理文本选择
                            MouseArea {
                                anchors.fill: parent
                                anchors.rightMargin: parent.width * 0.3 // 排除按钮区域
                                cursorShape: Qt.IBeamCursor
                                acceptedButtons: Qt.LeftButton
                                onPressed: {
                                    // 将点击事件传递给文本输入
                                    bigElevationSpeed.contentItem.forceActiveFocus()
                                    mouse.accepted = false // 让事件继续传播
                                }
                            }
                        }
                            
                            
                        // 上按钮
                        Button {
                            text: "↓"
                            Layout.preferredHeight: 80
                            Layout.preferredWidth: 120

                            onPressed: {
                                bridge.sendtoCpp({"method": "supportplatform.backward", "speed": bigElevationSpeed.realValue, "target": "platform.height"});
                            }

                            onReleased: {
                                bridge.sendtoCpp({"method": "supportplatform.stop", "target": "platform.height"});
                            }

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
                }
            }
        }

        RowLayout {
            spacing: 20

            Text {
                text: "方位反馈"
                font.pixelSize: 20
                color: "#333333"
                Layout.alignment: Qt.AlignVCenter
                Layout.minimumWidth: 80 // 保证文本区域宽度
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
                    text: azimuthPos
                    anchors.centerIn: parent
                    font.pixelSize: 16
                    font.bold: true
                    color: "#2E7D32"
                }
            }
            
            Text {
                text: "俯仰反馈"
                font.pixelSize: 20
                color: "#333333"
                Layout.alignment: Qt.AlignVCenter
                Layout.minimumWidth: 80 // 保证文本区域宽度
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
                    text: elevationPos
                    anchors.centerIn: parent
                    font.pixelSize: 16
                    font.bold: true
                    color: "#2E7D32"
                }
            }
            
            Text {
                text: "小升降台反馈"
                font.pixelSize: 20
                color: "#333333"
                Layout.alignment: Qt.AlignVCenter
                Layout.minimumWidth: 80 // 保证文本区域宽度
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
                    text: smallLiftPos
                    anchors.centerIn: parent
                    font.pixelSize: 16
                    font.bold: true
                    color: "#2E7D32"
                }
            }

            Text {
                text: "大升降台反馈"
                font.pixelSize: 20
                color: "#333333"
                Layout.alignment: Qt.AlignVCenter
                Layout.minimumWidth: 80 // 保证文本区域宽度
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
                    text: largeLiftPos
                    anchors.centerIn: parent
                    font.pixelSize: 16
                    font.bold: true
                    color: "#2E7D32"
                }
            }
        }

        RowLayout {
            spacing: 20

            Text {
                text: "方位状态"
                font.pixelSize: 20
                color: "#333333"
                Layout.alignment: Qt.AlignVCenter
                Layout.minimumWidth: 80 // 保证文本区域宽度
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
                    text: azimuthStatus
                    anchors.centerIn: parent
                    font.pixelSize: 16
                    font.bold: true
                    color: "#2E7D32"
                }
            }
            
            Text {
                text: "俯仰状态"
                font.pixelSize: 20
                color: "#333333"
                Layout.alignment: Qt.AlignVCenter
                Layout.minimumWidth: 80 // 保证文本区域宽度
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
                    text: elevationStatus
                    anchors.centerIn: parent
                    font.pixelSize: 16
                    font.bold: true
                    color: "#2E7D32"
                }
            }
            
            Text {
                text: "小升降台状态"
                font.pixelSize: 20
                color: "#333333"
                Layout.alignment: Qt.AlignVCenter
                Layout.minimumWidth: 80 // 保证文本区域宽度
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
                    text: smallLiftStatus
                    anchors.centerIn: parent
                    font.pixelSize: 16
                    font.bold: true
                    color: "#2E7D32"
                }
            }

            Text {
                text: "大升降台状态"
                font.pixelSize: 20
                color: "#333333"
                Layout.alignment: Qt.AlignVCenter
                Layout.minimumWidth: 80 // 保证文本区域宽度
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
                    text: largeLiftStatus
                    anchors.centerIn: parent
                    font.pixelSize: 16
                    font.bold: true
                    color: "#2E7D32"
                }
            }
        }
    }
}