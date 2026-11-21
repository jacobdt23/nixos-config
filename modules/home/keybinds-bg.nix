{ pkgs, lib, ... }:

let
  hasQuickshell = pkgs ? quickshell;

  toggle-keybinds-bg = pkgs.writeShellScriptBin "toggle-keybinds-bg" ''
    QML="$HOME/.config/conky/keybinds-bg.qml"
    LOCK="/tmp/toggle-keybinds-bg-''${UID}.lock"

    exec 9>"$LOCK"
    ${pkgs.util-linux}/bin/flock -n 9 || exit 0

    if ${pkgs.procps}/bin/pgrep -f "quickshell.*keybinds-bg\.qml|qs.*keybinds-bg\.qml" >/dev/null 2>&1; then
      if [ "''${1:-}" = "--start" ]; then
        exit 0
      fi
      ${pkgs.procps}/bin/pkill -f "quickshell.*keybinds-bg\.qml|qs.*keybinds-bg\.qml" || true
      if [ "''${1:-}" != "--restart" ]; then
        exit 0
      fi
      sleep 0.2
    fi

    if command -v qs >/dev/null 2>&1; then
      setsid qs -p "$QML" 9>&- >/dev/null 2>&1 </dev/null &
    elif command -v quickshell >/dev/null 2>&1; then
      setsid quickshell -p "$QML" 9>&- >/dev/null 2>&1 </dev/null &
    fi
  '';
in
{
  home.packages = [ toggle-keybinds-bg ]
    ++ lib.optionals hasQuickshell [ pkgs.quickshell ];

  home.file.".config/conky/keybinds-bg.qml".text = ''
    import Quickshell
    import Quickshell.Wayland
    import QtQuick

    ShellRoot {
      id: root

      readonly property var sections: [
        {
          title: "APPS",
          color: "#7aa2f7",
          items: [
            { key: "SUPER + RET", desc: "Terminal" },
            { key: "SUPER + B", desc: "Browser" },
            { key: "SUPER + E", desc: "Files" },
            { key: "SUPER + SPC", desc: "App launcher" },
            { key: "SUPER + Q", desc: "Power menu" },
            { key: "SUP+SHF+ESC", desc: "Activity (btop)" }
          ]
        },
        {
          title: "WINDOWS",
          color: "#bb9af7",
          items: [
            { key: "SUPER + C/W", desc: "Close" },
            { key: "SUPER + V", desc: "Float toggle" },
            { key: "SUPER + O", desc: "Pop out (pin)" },
            { key: "SUPER + F", desc: "Fullscreen" },
            { key: "SUPER + J", desc: "Toggle split" },
            { key: "SUPER + TAB", desc: "Next monitor" },
            { key: "SUPER + 1..0", desc: "Workspaces" },
            { key: "SUP+SHF+1..0", desc: "Move to ws" },
            { key: "SUPER + S", desc: "Scratchpad" },
            { key: "MID CLICK", desc: "Drag window" },
            { key: "SUPER + RMB", desc: "Resize" }
          ]
        },
        {
          title: "TOOLS & MEDIA",
          color: "#7dcfff",
          items: [
            { key: "SUP+SHF + S", desc: "Screenshot" },
            { key: "SHF + PRINT", desc: "Full screen shot" },
            { key: "SUP+SHF + V", desc: "Clipboard" },
            { key: "SUPER + -/=", desc: "Volume - / +" },
            { key: "SUPER + BKSP", desc: "Mute" },
            { key: "SUP+CTL + L", desc: "Lock screen" },
            { key: "SUP+SHF + R", desc: "Reload Hyprland" },
            { key: "SUPER + K", desc: "Toggle cheatsheet" }
          ]
        }
      ]

      Variants {
        model: Quickshell.screens

        PanelWindow {
          required property var modelData

          screen: modelData
          color: "transparent"
          anchors { top: true; bottom: true; left: true; right: true }
          exclusionMode: ExclusionMode.Ignore
          WlrLayershell.namespace: "conky-keybinds-bg"
          WlrLayershell.layer: WlrLayer.Bottom
          WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
          mask: Region {}

          Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 22
            anchors.verticalCenter: parent.verticalCenter
            width: 304
            height: Math.min(cardCol.implicitHeight + 28, parent.height - 90)
            radius: 10
            color: "#1a1b26"
            border.width: 1
            border.color: "#7aa2f7"

            Column {
              id: cardCol
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              anchors.leftMargin: 16
              anchors.rightMargin: 16
              spacing: 10

              Item {
                width: parent.width
                height: 20

                Text {
                  anchors.left: parent.left
                  anchors.verticalCenter: parent.verticalCenter
                  text: "  KEYBINDINGS"
                  color: "#7aa2f7"
                  font.family: "JetBrainsMono Nerd Font"
                  font.pixelSize: 12
                  font.bold: true
                  font.letterSpacing: 1.0
                }

                Text {
                  anchors.right: parent.right
                  anchors.verticalCenter: parent.verticalCenter
                  text: "SUPER + K"
                  color: "#565f89"
                  font.family: "JetBrainsMono Nerd Font"
                  font.pixelSize: 10
                }
              }

              Rectangle {
                width: parent.width
                height: 1
                color: "#414868"
              }

              Repeater {
                model: root.sections

                Column {
                  required property var modelData
                  width: cardCol.width
                  spacing: 4

                  Row {
                    spacing: 6
                    topPadding: 2
                    bottomPadding: 2

                    Rectangle {
                      width: 6
                      height: 6
                      radius: 3
                      color: modelData.color || "#7aa2f7"
                      anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                      text: modelData.title || ""
                      color: modelData.color || "#7aa2f7"
                      font.family: "JetBrainsMono Nerd Font"
                      font.pixelSize: 10
                      font.bold: true
                      font.letterSpacing: 1.2
                    }
                  }

                  Repeater {
                    model: modelData.items || []

                    Item {
                      required property var modelData
                      width: cardCol.width
                      height: 20

                      Rectangle {
                        id: keyPill
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: keyLabel.implicitWidth + 12
                        height: 18
                        radius: 4
                        color: "#24283b"
                        border.width: 1
                        border.color: "#414868"

                        Text {
                          id: keyLabel
                          anchors.centerIn: parent
                          text: modelData.key || ""
                          color: "#7dcfff"
                          font.family: "JetBrainsMono Nerd Font"
                          font.pixelSize: 10
                          font.bold: true
                        }
                      }

                      Text {
                        anchors.right: parent.right
                        anchors.left: keyPill.right
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignRight
                        elide: Text.ElideRight
                        text: modelData.desc || ""
                        color: "#c0caf5"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
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
  '';
}
