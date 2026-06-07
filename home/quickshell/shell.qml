//@ pragma UseQApplication
import QtQuick
import QtQml
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.SystemTray

Scope {
    id: global
    property bool showCalender: false
    property bool showControlCenter: false

    PanelWindow {
        id: root
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: 32
        color: "#1e1e2e"

        property string currentTime: new Date().toLocaleTimeString(Qt.locale("ja_JP"), "HH:mm:ss")
        property string currentWorkspace: "?"   // ✅ 結果を受け取る変数
        property string currentIme: "?"         // ✅ 結果を受け取る変数
        property string currentBattery: "?"
        property string currentVolume: "?"

        Item {
            id: logicContainer

            // --- 1. ワークスペース ---
            Process {
                id: wsProcess
                command: ["sh", "-c", "niri msg -j workspaces | jq -r '.[] | select(.is_focused) | .idx'"]
                running: true
                stdout: StdioCollector {                          // ✅ パーサー指定
                    onStreamFinished: root.currentWorkspace = this.text.trim()
                }
            }
            Timer {
                interval: 200
                running: true
                repeat: true
                onTriggered: wsProcess.running = true            // ✅ falseにしなくていい
            }

            // --- 2. 時計 ---
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: root.currentTime = Qt.formatDateTime(new Date(), "yyyy/MM/dd HH:mm:ss")
            }

            // --- 3. IME ---
            Process {
                id: imeProcess
                command: ["fcitx5-remote", "-n"]
                running: true
                stdout: StdioCollector {                          // ✅ パーサー指定
                    onStreamFinished: root.currentIme = this.text.trim()
                }
            }
            Timer {
                interval: 500
                running: true
                repeat: true
                onTriggered: imeProcess.running = true
            }

            // --- 4. バッテリー ---
            Process {
                id: batteryProcess
                command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/capacity"]
                running: true
                stdout: StdioCollector {
                    onStreamFinished: root.currentBattery = this.text.trim()
                }
            }
            Timer {
                interval: 5000
                running: true
                repeat: true
                onTriggered: batteryProcess.running = true
            }

            // --- 5. 音量 ---
            Process {
                id: volProcess
                command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
                running: true
                stdout: StdioCollector {
                    onStreamFinished: {
                        let out = this.text.trim();
                        if (out.indexOf("[MUTED]") !== -1) {
                            root.currentVolume = "MUTED";
                        } else {
                            let numStr = out.replace("Volume: ", "");
                            let vol = Math.round(parseFloat(numStr) * 100);
                            root.currentVolume = vol + "%";
                        }
                    }
                }
            }
            Timer {
                interval: 500
                running: true
                repeat: true
                onTriggered: volProcess.running = true
            }
            Process {
                id: volToggleProcess
                command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
            }
            Process {
                id: volUpProcess
                command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+"]
            }
            Process {
                id: volDownProcess
                command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]
            }
            // 6.カレンダー
            Process {
                id: calendarPopup
                command: ["foot", "--app-id=qs-calendar", "-e", "bash", "-c", "cal -3 && read -n 1 -s"]
            }
        }

        Text {
            anchors {
                left: parent.left
                leftMargin: 16
                verticalCenter: parent.verticalCenter
            }
            color: "#a6e3a1"
            text: "Workspace: " + root.currentWorkspace    // ✅ プロパティから読む
        }
        Text {
            anchors.centerIn: parent
            color: "#cdd6f4"
            font.bold: true
            font.pixelSize: 15
            text: root.currentTime
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    global.showCalender = !global.showCalender;
                }
            }
        }

        Row {
            anchors {
                right: parent.right
                rightMargin: 16
                verticalCenter: parent.verticalCenter
            }
            spacing: 16

            // --- System Tray ---
            Row {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter
                Repeater {
                    model: SystemTray.items
                    delegate: Item {
                        width: 20
                        height: 20
                        anchors.verticalCenter: parent.verticalCenter

                        IconImage {
                            id: trayIcon
                            anchors.fill: parent
                            source: {
                                if (!modelData.icon) return "";
                                var src = modelData.icon.toString();
                                if (src.indexOf("keyboard-") !== -1 && src.indexOf("input-keyboard") === -1) {
                                    return "input-keyboard";
                                }
                                return modelData.icon;
                            }
                        }

                        QsMenuAnchor {
                            id: menuAnchor
                            menu: modelData.menu
                            anchor {
                                window: root
                            }
                        }

                        MouseArea {
                            id: trayMouseArea
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: (mouse) => {
                                if (mouse.button === Qt.RightButton) {
                                    if (modelData.hasMenu) {
                                        menuAnchor.open()
                                    }
                                } else {
                                    modelData.activate()
                                }
                            }
                        }
                    }
                }
            }

            Text {
                color: "#cdd6f4"
                text: "Volume: " + root.currentVolume
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        volToggleProcess.running = true;
                        volProcess.running = true;
                    }

                    onWheel: wheel => {
                        if (wheel.angleDelta.y > 0) {
                            volUpProcess.running = true;
                        } else {
                            volDownProcess.running = true;
                        }
                        volProcess.running = true;
                    }
                }
            }

            Text {
                color: "#cdd6f4"
                text: "IME: " + root.currentIme               // ✅ プロパティから読む
            }
            Text {
                color: "#cdd6f4"
                text: "Battery: " + root.currentBattery       // ✅ プロパティから読む
            }
            Text {
                color: "#cdd6f4"
                text: "⚙️"
                font.pixelSize: 14
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        global.showControlCenter = !global.showControlCenter;
                    }
                }
            }
        }
    }
    PanelWindow {
        id: calenderWidget
        visible: global.showCalender
        anchors {
            top: true
            left: true
            right: true
        }
        margins.top: 40
        exclusiveZone: 0
        implicitHeight: 200
        color: "transparent"

        Rectangle {
            width: 230
            height: 200
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#1e1e2e"
            border.color: "#89b4fa"
            border.width: 2
            radius: 12
            Text {
                id: calText
                anchors.centerIn: parent
                color: "#cdd6f4"
                font.family: "monospace"
                font.pixelSize: 15
                text: "Loading..."
            }
        }
        Process {
            command: ["cal"]
            running: global.showCalender
            stdout: StdioCollector {
                onStreamFinished: calText.text = this.text
            }
        }
    }

    PanelWindow {
        id: controlCenterWidget
        visible: global.showControlCenter
        anchors {
            top: true
            left: true
            right: true
        }
        margins.top: 40
        exclusiveZone: 0
        implicitHeight: 380
        color: "transparent"

        ControlCenter {
            anchors.right: parent.right
            anchors.rightMargin: 16
        }
    }
}
