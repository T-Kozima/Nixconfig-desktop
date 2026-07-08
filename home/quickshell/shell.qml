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
        implicitHeight: 30
        color: "#d91a1b26" // Tokyo Night Storm + 85% opacity (with blur from niri)
        namespace: "quickshell-bar"

        property string currentTime: ""
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
                stdout: StdioCollector {
                    onStreamFinished: root.currentWorkspace = this.text.trim()
                }
            }
            Timer {
                interval: 200
                running: true
                repeat: true
                onTriggered: wsProcess.running = true
            }

            // --- 2. 時計 ---
            Timer {
                interval: 1000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: root.currentTime = Qt.formatDateTime(new Date(), "M月d日(ddd) H:mm")
            }

            // --- 3. IME ---
            Process {
                id: imeProcess
                command: ["fcitx5-remote", "-n"]
                running: true
                stdout: StdioCollector {
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
                command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 100"]
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
        }

        // Left section (macOS Apple menu style & workspace)
        Row {
            anchors {
                left: parent.left
                leftMargin: 16
                verticalCenter: parent.verticalCenter
            }
            spacing: 12

            Text {
                text: ""
                color: "#7aa2f7"
                font.bold: true
                font.pixelSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "Finder"
                color: "#c0caf5"
                font.bold: true
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "WS: " + root.currentWorkspace
                color: "#a9b1d6"
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Center Section: Localized Date/Time (macOS Style)
        Text {
            anchors.centerIn: parent
            color: "#c0caf5"
            font.bold: true
            font.pixelSize: 13
            text: root.currentTime
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    global.showCalender = !global.showCalender;
                }
            }
        }

        // Right Section: Status icons & system settings
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
                        width: 18
                        height: 18
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
                color: "#c0caf5"
                font.pixelSize: 12
                text: "🔊 " + root.currentVolume
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
                color: "#c0caf5"
                font.pixelSize: 12
                text: "⌨️ " + root.currentIme
            }

            Text {
                color: "#c0caf5"
                font.pixelSize: 12
                text: "🔋 " + root.currentBattery + "%"
            }

            Text {
                color: "#7aa2f7"
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
        margins.top: 36
        exclusiveZone: 0
        implicitHeight: 200
        color: "transparent"

        Rectangle {
            width: 230
            height: 200
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#d91e1f29" // Tokyo Night Night + 85% opacity
            border.color: "#3b4261"
            border.width: 1
            radius: 14
            Text {
                id: calText
                anchors.centerIn: parent
                color: "#c0caf5"
                font.family: "monospace"
                font.pixelSize: 14
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
        margins.top: 36
        exclusiveZone: 0
        implicitHeight: 380
        color: "transparent"

        ControlCenter {
            anchors.right: parent.right
            anchors.rightMargin: 16
        }
    }

    //  macOS Style Dock at the bottom (Tokyo Night theme)
    PanelWindow {
        id: dockWindow
        anchors {
            bottom: true
            horizontalCenter: parent.horizontalCenter
        }
        margins.bottom: 10
        exclusiveZone: 0
        implicitHeight: 64
        implicitWidth: dockRow.width + 32
        color: "transparent"
        namespace: "quickshell-dock"

        Rectangle {
            anchors.fill: parent
            color: "#d916161e" // Tokyo Night + 85% opacity
            border.color: "#3b4261"
            border.width: 1
            radius: 20

            // Inner glass sheen
            Rectangle {
                width: parent.width
                height: 1
                color: "#ffffff15"
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                radius: 20
            }
        }

        Row {
            id: dockRow
            anchors.centerIn: parent
            spacing: 16
            padding: 8

            // Icon theme names of the favorite apps
            readonly property var apps: [
                { icon: "floorp", cmd: "floorp" },
                { icon: "alacritty", cmd: "alacritty" },
                { icon: "utilities-terminal", cmd: "foot" },
                { icon: "zed", cmd: "zed" },
                { icon: "obsidian", cmd: "obsidian" },
                { icon: "system-file-manager", cmd: "thunar" }
            ]

            Repeater {
                model: dockRow.apps
                delegate: Item {
                    width: 48
                    height: 48

                    Rectangle {
                        id: bgHighlight
                        anchors.fill: parent
                        color: "#ffffff12"
                        radius: 12
                        visible: mouseArea.containsMouse
                    }

                    IconImage {
                        id: appIcon
                        anchors.fill: parent
                        anchors.margins: 4
                        source: "image://icon/" + modelData.icon
                        smooth: true
                        
                        // Zoom in animation on hover
                        scale: mouseArea.containsMouse ? 1.18 : 1.0
                        Behavior on scale {
                            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            launchProcess.command = [modelData.cmd];
                            launchProcess.running = true;
                        }
                    }

                    Process {
                        id: launchProcess
                    }
                }
            }
        }
    }
}
