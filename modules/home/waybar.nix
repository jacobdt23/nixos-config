{ ... }:

{
  # ===========================================================================
  # WAYBAR (Top Bar + Bottom Dock)
  # ===========================================================================
  home.file.".config/waybar/config.jsonc".text = ''
    [
        {
            "name": "top-bar",
            "layer": "top",
            "position": "top",
            "height": 34,
            "margin-top": 6,
            "margin-left": 12,
            "margin-right": 12,
            "spacing": 4,
            "modules-left": [
                "custom/brand",
                "hyprland/workspaces"
            ],
            "modules-center": [
                "clock",
                "custom/media"
            ],
            "modules-right": [
                "cpu",
                "memory",
                "disk",
                "wireplumber",
                "network",
                "custom/power"
            ],
            "custom/brand": {
                "format": "󱄅  NixOS",
                "tooltip": false,
                "on-click": "rofi -show drun"
            },
            "hyprland/workspaces": {
                "disable-scroll": true,
                "all-outputs": true,
                "format": "{name}",
                "on-click": "activate"
            },
            "clock": {
                "format": "󰥔  {:%a, %b %d • %I:%M %p}",
                "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
            },
            "custom/media": {
                "format": "󰎆  Media",
                "tooltip": false,
                "on-click": "pavucontrol"
            },
            "cpu": {
                "interval": 2,
                "format": "󰻠 {usage}%",
                "tooltip": false,
                "on-click": "kitty -e btop"
            },
            "memory": {
                "interval": 2,
                "format": "󰍛 {percentage}%",
                "tooltip": false,
                "on-click": "kitty -e btop"
            },
            "disk": {
                "interval": 30,
                "format": "󰋊 {percentage_used}%",
                "path": "/",
                "on-click": "kitty -e df -h"
            },
            "wireplumber": {
                "format": "{icon} {volume}%",
                "format-muted": "󰝟 Muted",
                "format-icons": ["", "", ""],
                "on-click": "pavucontrol"
            },
            "network": {
                "format-ethernet": "󰈀",
                "format-wifi": "󰖩",
                "format-disconnected": "󰈂",
                "tooltip-format": "{ifname}: {ipaddr}/{cidr}",
                "on-click": "nm-connection-editor"
            },
            "wlr/taskbar": {
                "format": "{icon}",
                "icon-size": 18,
                "tooltip-format": "{title}",
                "on-click": "activate",
                "on-click-middle": "close",
                "all-outputs": false,
                "ignore-list": [
                    "rofi"
                ]
            },
            "custom/power": {
                "format": " ⏻ ",
                "tooltip": false,
                "on-click": "hyprctl dispatch exit"
            }
        },
        {
            "name": "bottom-dock",
            "layer": "top",
            "position": "bottom",
            "height": 44,
            "margin-bottom": 6,
            "margin-left": 12,
            "margin-right": 12,
            "spacing": 6,
            "modules-left": [
                "custom/start",
                "custom/search"
            ],
            "modules-center": [
                "custom/term",
                "custom/files",
                "custom/web"
            ],
            "modules-right": [
                "custom/clipboard",
                "custom/snip",
                "custom/keys",
                "custom/showdesktop"
            ],
            "custom/start": {
                "format": "󱄅  Start",
                "tooltip": false,
                "on-click": "rofi -show drun"
            },
            "custom/search": {
                "format": "󰍏  Search apps...",
                "tooltip": false,
                "on-click": "rofi -show drun"
            },
            "custom/term": {
                "format": "󰞷  Term",
                "tooltip": false,
                "on-click": "kitty"
            },
            "custom/files": {
                "format": "󰉋  Files",
                "tooltip": false,
                "on-click": "thunar"
            },
            "custom/web": {
                "format": "󰈹  Web",
                "tooltip": false,
                "on-click": "brave"
            },
            "custom/clipboard": {
                "format": "󰅍  Clipboard",
                "tooltip": false,
                "on-click": "hypr-clipboard"
            },
            "custom/snip": {
                "format": "󰄀  Snip",
                "tooltip": false,
                "on-click": "hypr-screenshot",
                "on-click-right": "hypr-screenshot config"
            },
            "custom/keys": {
                "format": "󰌌  Keys",
                "tooltip": false,
                "on-click": "notify-send 'Keybinds' 'Super+Return: Terminal\nSuper+Space: App Launcher\nSuper+E: Files\nSuper+B: Browser\nSuper+C: Close Window\nSuper+L: Lock Screen'"
            },
            "tray": {
                "icon-size": 16,
                "spacing": 6
            },
            "custom/showdesktop": {
                "format": " ",
                "tooltip": false,
                "on-click": "hyprctl dispatch workspace special:magic"
            }
        }
    ]
  '';

  home.file.".config/waybar/style.css".text = ''
    * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 11px;
        color: #c0caf5;
        min-height: 0;
    }

    window#waybar.top-bar {
        background-color: rgba(20, 22, 34, 0.78);
        border: 1px solid rgba(122, 162, 247, 0.28);
        border-radius: 12px;
    }

    window#waybar.bottom-dock {
        background-color: rgba(20, 22, 34, 0.78);
        border: 1px solid rgba(122, 162, 247, 0.28);
        border-radius: 14px;
    }

    #custom-brand {
        background: linear-gradient(135deg, rgba(31, 35, 53, 0.8) 0%, rgba(36, 40, 59, 0.8) 100%);
        border: 1px solid rgba(122, 162, 247, 0.3);
        border-radius: 8px;
        padding: 2px 10px;
        margin: 4px 4px 4px 8px;
        color: #7aa2f7;
        font-weight: 900;
    }

    #custom-brand:hover {
        background: linear-gradient(135deg, #24283b 0%, #2f354f 100%);
        border-color: #7aa2f7;
    }

    #workspaces {
        background: transparent;
        margin: 4px 2px;
    }

    #workspaces button {
        background-color: rgba(26, 27, 38, 0.7);
        border: 1px solid rgba(41, 46, 66, 0.8);
        border-radius: 7px;
        padding: 2px 6px;
        margin: 0 2px;
        color: #565f89;
        font-weight: bold;
        font-size: 10px;
        min-width: 20px;
        transition: all 0.2s ease;
    }

    #workspaces button:hover {
        background-color: #2f354f;
        border-color: #7aa2f7;
        color: #c0caf5;
    }

    #workspaces button.active {
        background: linear-gradient(135deg, #7aa2f7 0%, #bb9af7 100%);
        border: 1px solid #7aa2f7;
        color: #14161f;
        font-weight: 900;
    }

    #window {
        background-color: rgba(26, 27, 38, 0.7);
        border: 1px solid rgba(41, 46, 66, 0.8);
        border-radius: 8px;
        padding: 2px 10px;
        margin: 4px 6px;
        color: #7dcfff;
        font-size: 10px;
    }

    #clock,
    #custom-media,
    #cpu,
    #memory,
    #disk,
    #wireplumber,
    #network,
    #tray {
        background-color: rgba(26, 27, 38, 0.7);
        border: 1px solid rgba(41, 46, 66, 0.8);
        border-radius: 8px;
        padding: 2px 9px;
        margin: 4px 3px;
        font-size: 10px;
    }

    #clock {
        border-color: rgba(122, 162, 247, 0.35);
        color: #7dcfff;
        font-weight: bold;
    }

    #clock:hover,
    #custom-media:hover,
    #wireplumber:hover {
        background-color: #24283b;
        border-color: #7aa2f7;
    }

    #cpu { color: #7aa2f7; }
    #memory { color: #bb9af7; }
    #disk { color: #e0af68; }
    #network { color: #7dcfff; }
    #wireplumber { color: #9ece6a; }

    #custom-power {
        background-color: #14161f;
        border: 1px solid #f7768e;
        border-radius: 7px;
        padding: 2px 8px;
        margin: 4px 8px 4px 3px;
        color: #f7768e;
        font-weight: bold;
    }

    #custom-power:hover {
        background-color: #f7768e;
        color: #14161f;
    }

    #custom-start {
        background: linear-gradient(135deg, #1f2335 0%, #24283b 100%);
        border: 1px solid rgba(122, 162, 247, 0.35);
        border-radius: 9px;
        padding: 4px 12px;
        margin: 5px 4px 5px 8px;
        color: #c0caf5;
        font-weight: bold;
    }

    #custom-start:hover {
        background: linear-gradient(135deg, #24283b 0%, #2f354f 100%);
        border-color: #7aa2f7;
    }

    #custom-search {
        background-color: #1a1b26;
        border: 1px solid #292e42;
        border-radius: 8px;
        padding: 4px 12px;
        margin: 5px 6px 5px 2px;
        color: #7982a9;
        font-size: 10px;
    }

    #custom-search:hover {
        background-color: #24283b;
        border-color: #7aa2f7;
        color: #c0caf5;
    }

    #taskbar { margin: 4px 0; }

    #taskbar button {
        background-color: transparent;
        border: 1px solid transparent;
        border-bottom: 2px solid rgba(122, 162, 247, 0.45);
        border-radius: 8px;
        padding: 2px 8px;
        margin: 0 3px;
        transition: all 0.2s ease;
    }

    #taskbar button:hover {
        background-color: #24283b;
        border-color: #3b4261;
        border-bottom-color: #7aa2f7;
    }

    #taskbar button.active {
        background-color: #24283b;
        border-color: #3b4261;
        border-bottom: 2px solid #7aa2f7;
    }

    #custom-term,
    #custom-files,
    #custom-web,
    #custom-clipboard,
    #custom-snip,
    #custom-keys {
        background-color: rgba(26, 27, 38, 0.7);
        border: 1px solid rgba(41, 46, 66, 0.8);
        border-radius: 8px;
        padding: 3px 9px;
        margin: 5px 3px;
        font-size: 10px;
        color: #c0caf5;
    }

    #custom-term:hover,
    #custom-files:hover,
    #custom-web:hover,
    #custom-clipboard:hover,
    #custom-snip:hover,
    #custom-keys:hover {
        background-color: #24283b;
        border-color: #7aa2f7;
    }

    #custom-showdesktop {
        background-color: #292e42;
        border-radius: 4px;
        min-width: 6px;
        padding: 0;
        margin: 8px 8px 8px 4px;
    }

    #custom-showdesktop:hover {
        background-color: #7aa2f7;
    }
  '';
}
