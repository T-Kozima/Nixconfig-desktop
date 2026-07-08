import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Rectangle {
    id: ccContainer
    width: 320
    height: 380
    color: "#e616161f" // Tokyo Night Night + 90% opacity (with blur from niri)
    border.color: "#3b4261"
    border.width: 1
    radius: 16

    // PipeWire audio helpers
    readonly property var defaultSink: Pipewire.defaultAudioSink
    readonly property real volume: defaultSink && defaultSink.audio ? defaultSink.audio.volume : 0.0
    readonly property bool muted: defaultSink && defaultSink.audio ? defaultSink.audio.muted : false

    Process {
        id: wpctlProcess
    }

    function setVolume(v) {
        wpctlProcess.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", v.toFixed(2)];
        wpctlProcess.running = true;
    }

    function toggleMute() {
        wpctlProcess.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"];
        wpctlProcess.running = true;
    }

    // Redshift/Gammastep helpers
    property bool redshiftActive: false
    Process {
        id: redshiftCheckProcess
        command: ["pgrep", "gammastep"]
        stdout: StdioCollector {
            onStreamFinished: redshiftActive = this.text.trim().length > 0
        }
    }
    Timer {
        interval: 1500
        running: ccContainer.visible
        repeat: true
        onTriggered: redshiftCheckProcess.running = true
    }
    Process {
        id: redshiftToggleProcess
        command: ["sh", "-c", "pgrep gammastep && pkill gammastep || gammastep -O 4000 -m wayland &"]
        onRunningChanged: if (!running) redshiftCheckProcess.running = true
    }

    // IME process for toggling fcitx5 input method
    Process {
        id: imeToggleProcess
        command: ["fcitx5-remote", "-t"]
    }

    // Power Actions
    Process {
        id: powerProcess
    }

    function runPowerAction(action) {
        if (action === "suspend") {
            powerProcess.command = ["systemctl", "suspend"];
        } else if (action === "reboot") {
            powerProcess.command = ["systemctl", "reboot"];
        } else if (action === "poweroff") {
            powerProcess.command = ["systemctl", "poweroff"];
        }
        powerProcess.running = true;
    }

    // UI Content
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 16

        // 1. Header Section
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            
            Rectangle {
                width: 44
                height: 44
                radius: 22
                color: "#2e3c64" // Tokyo Night Dark Surface
                Text {
                    anchors.centerIn: parent
                    text: "👤"
                    font.pixelSize: 22
                }
            }

            ColumnLayout {
                spacing: 2
                Text {
                    text: "chronotokei"
                    color: "#c0caf5"
                    font.bold: true
                    font.pixelSize: 15
                }
                Text {
                    text: "NixOS / Niri Desktop"
                    color: "#a9b1d6"
                    font.pixelSize: 11
                }
            }
            
            Item { Layout.fillWidth: true } // spacer
            
            // Close Button
            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: closeMouse.containsMouse ? "#3b4261" : "#24283b"
                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: "#c0caf5"
                    font.pixelSize: 12
                }
                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: global.showControlCenter = false
                }
            }
        }

        // Horizontal Line
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#3b4261"
        }

        // 2. Quick Toggles Grid (2x2)
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 10
            columnSpacing: 10

            // Mute Toggle
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 10
                color: ccContainer.muted ? "#f7768e" : "#24283b"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    Text {
                        text: ccContainer.muted ? "🔇" : "🔊"
                        font.pixelSize: 16
                    }
                    Text {
                        text: ccContainer.muted ? "消音中" : "消音"
                        color: ccContainer.muted ? "#1d202f" : "#c0caf5"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: toggleMute()
                }
            }

            // IME Toggle (Mozc/Fcitx5)
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 10
                color: root.currentIme === "mozc" ? "#7aa2f7" : "#24283b"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    Text {
                        text: "⌨️"
                        font.pixelSize: 16
                    }
                    Text {
                        text: "IME: " + root.currentIme
                        color: root.currentIme === "mozc" ? "#1d202f" : "#c0caf5"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        imeToggleProcess.running = true;
                    }
                }
            }

            // Night Light Toggle
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 10
                color: ccContainer.redshiftActive ? "#e0af68" : "#24283b"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    Text {
                        text: ccContainer.redshiftActive ? "🌙" : "☀️"
                        font.pixelSize: 16
                    }
                    Text {
                        text: "夜間モード"
                        color: ccContainer.redshiftActive ? "#1d202f" : "#c0caf5"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        redshiftToggleProcess.running = true;
                    }
                }
            }

            // Calendar Widget Toggle
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 10
                color: global.showCalender ? "#9ece6a" : "#24283b"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    Text {
                        text: "📅"
                        font.pixelSize: 16
                    }
                    Text {
                        text: "カレンダー"
                        color: global.showCalender ? "#1d202f" : "#c0caf5"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        global.showCalender = !global.showCalender;
                    }
                }
            }
        }

        // Spacer
        Item { Layout.fillHeight: true }

        // 3. Audio Volume Slider Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "音量"
                    color: "#a9b1d6"
                    font.pixelSize: 11
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: ccContainer.muted ? "消音中" : Math.round(ccContainer.volume * 100) + "%"
                    color: "#c0caf5"
                    font.pixelSize: 12
                    font.bold: true
                }
            }

            // Slider BG
            Rectangle {
                id: sliderBg
                Layout.fillWidth: true
                height: 12
                color: "#24283b"
                radius: 6

                // Active Fill
                Rectangle {
                    width: Math.max(0, Math.min(sliderBg.width, sliderBg.width * ccContainer.volume))
                    height: parent.height
                    color: ccContainer.muted ? "#414868" : "#7aa2f7"
                    radius: 6
                }

                // Drag handling
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.SizeHorCursor
                    onPositionChanged: (mouse) => {
                        if (pressed) {
                            let val = Math.max(0.0, Math.min(1.0, mouse.x / sliderBg.width));
                            ccContainer.setVolume(val);
                        }
                    }
                    onPressed: (mouse) => {
                        let val = Math.max(0.0, Math.min(1.0, mouse.x / sliderBg.width));
                        ccContainer.setVolume(val);
                    }
                }
            }
        }

        // Spacer
        Item { Layout.fillHeight: true }

        // Horizontal Line
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#3b4261"
        }

        // 4. Power Actions Footer
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            // Suspend Button
            Rectangle {
                Layout.fillWidth: true
                height: 38
                radius: 8
                color: suspMouse.containsMouse ? "#3b4261" : "#24283b"
                Text {
                    anchors.centerIn: parent
                    text: "💤 サスペンド"
                    color: "#c0caf5"
                    font.pixelSize: 11
                    font.bold: true
                }
                MouseArea {
                    id: suspMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ccContainer.runPowerAction("suspend")
                }
            }

            // Reboot Button
            Rectangle {
                Layout.fillWidth: true
                height: 38
                radius: 8
                color: rebMouse.containsMouse ? "#3b4261" : "#24283b"
                Text {
                    anchors.centerIn: parent
                    text: "🔄 再起動"
                    color: "#c0caf5"
                    font.pixelSize: 11
                    font.bold: true
                }
                MouseArea {
                    id: rebMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ccContainer.runPowerAction("reboot")
                }
            }

            // Poweroff Button
            Rectangle {
                Layout.fillWidth: true
                height: 38
                radius: 8
                color: pwrMouse.containsMouse ? "#f7768e" : "#24283b"
                Text {
                    anchors.centerIn: parent
                    text: "🔌 シャットダウン"
                    color: pwrMouse.containsMouse ? "#1d202f" : "#f7768e"
                    font.pixelSize: 11
                    font.bold: true
                }
                MouseArea {
                    id: pwrMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ccContainer.runPowerAction("poweroff")
                }
            }
        }
    }
}
