{ ... }:

{
  # ===========================================================================
  # WAYBAR (Unified Top Bar)
  # ===========================================================================
  home.file.".config/waybar/config.jsonc".text = ''
    [
        {
            "name": "top-bar",
            "layer": "top",
            "position": "top",
            "height": 38,
            "margin-top": 6,
            "margin-left": 12,
            "margin-right": 12,
            "spacing": 6,
            "modules-left": [
                "custom/brand",
                "hyprland/workspaces",
                "custom/term",
                "custom/files",
                "custom/web"
            ],
            "modules-center": [
                "clock",
                "custom/media"
            ],
            "modules-right": [
                "custom/clipboard",
                "custom/snip",
                "custom/keys",
                "cpu",
                "memory",
                "disk",
                "wireplumber",
                "network",
                "tray",
                "custom/power"
            ],
            "custom/brand": {
                "format": "󱄅",
                "tooltip": false,
                "on-click": "rofi -show drun"
            },
            "hyprland/workspaces": {
                "disable-scroll": true,
                "all-outputs": true,
                "format": "{name}",
                "on-click": "activate"
            },
            "custom/term": {
                "format": "󰞷",
                "tooltip-format": "Terminal (Kitty)",
                "on-click": "kitty"
            },
            "custom/files": {
                "format": "󰉋",
                "tooltip-format": "File Manager (Thunar)",
                "on-click": "thunar"
            },
            "custom/web": {
                "format": "󰈹",
                "tooltip-format": "Web Browser (Brave)",
                "on-click": "brave"
            },
            "clock": {
                "format": "󰥔  {:%a, %b %d • %I:%M %p}",
                "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
                "on-click": "notify-send 'Calendar' \"$(cal)\""
            },
            "custom/media": {
                "format": "󰎆",
                "tooltip": false,
                "on-click": "pavucontrol"
            },
            "custom/clipboard": {
                "format": "󰅍",
                "tooltip-format": "Clipboard History",
                "on-click": "hypr-clipboard"
            },
            "custom/snip": {
                "format": "󰄀",
                "tooltip-format": "Screenshot Tool",
                "on-click": "hypr-screenshot",
                "on-click-right": "hypr-screenshot config"
            },
            "custom/keys": {
                "format": "󰌌",
                "tooltip-format": "Show Shortcuts",
                "on-click": "notify-send 'Keybinds' 'Super+Return: Terminal\nSuper+Space: App Launcher\nSuper+E: Files\nSuper+B: Browser\nSuper+C: Close Window\nSuper+L: Lock Screen'"
            },
            "cpu": {
                "interval": 2,
                "format": "󰻠 {usage}%",
                "tooltip": false,
                "on-click": "kitty -e btop"
            },
            "memory": {
                "interval": 2,
                "format": "󰍛 {used:0.1f}G ({percentage}%)",
                "tooltip": false,
                "on-click": "kitty -e btop"
            },
            "disk": {
                "interval": 30,
                "format": "󰋊 {free} ({percentage_used}%)",
                "path": "/",
                "on-click": "kitty -e btop"
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
            "tray": {
                "icon-size": 16,
                "spacing": 6
            },
            "custom/power": {
                "format": " ⏻ ",
                "tooltip": false,
                "on-click": "hyprctl dispatch exit"
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
        margin: 4px 2px;
        color: #c0caf5;
        font-weight: bold;
    }

    #clock {
        background-color: rgba(26, 27, 38, 0.7);
        border: 1px solid rgba(41, 46, 66, 0.8);
        border-radius: 8px;
        padding: 2px 12px;
        margin: 4px 2px;
        color: #7dcfff;
        font-weight: 900;
    }

    #custom-media {
        background-color: rgba(26, 27, 38, 0.7);
        border: 1px solid rgba(41, 46, 66, 0.8);
        border-radius: 8px;
        padding: 2px 10px;
        margin: 4px 2px;
        color: #bb9af7;
        font-weight: bold;
    }

    #cpu, #memory, #disk {
        background-color: rgba(26, 27, 38, 0.7);
        border: 1px solid rgba(41, 46, 66, 0.8);
        border-radius: 8px;
        padding: 2px 8px;
        margin: 4px 2px;
        font-weight: bold;
    }

    #cpu {
        color: #7aa2f7;
    }

    #memory {
        color: #bb9af7;
    }

    #disk {
        color: #e0af68;
    }

    #wireplumber {
        background-color: rgba(26, 27, 38, 0.7);
        border: 1px solid rgba(41, 46, 66, 0.8);
        border-radius: 8px;
        padding: 2px 8px;
        margin: 4px 2px;
        color: #9ece6a;
        font-weight: bold;
    }

    #network {
        background-color: rgba(26, 27, 38, 0.7);
        border: 1px solid rgba(41, 46, 66, 0.8);
        border-radius: 8px;
        padding: 2px 8px;
        margin: 4px 2px;
        color: #7dcfff;
        font-weight: bold;
    }

    #custom-term, #custom-files, #custom-web, #custom-clipboard, #custom-snip, #custom-keys {
        background-color: rgba(26, 27, 38, 0.7);
        border: 1px solid rgba(41, 46, 66, 0.8);
        border-radius: 8px;
        padding: 2px 8px;
        margin: 4px 2px;
        color: #c0caf5;
        font-weight: bold;
        transition: all 0.2s ease;
    }

    #custom-term:hover, #custom-files:hover, #custom-web:hover,
    #custom-clipboard:hover, #custom-snip:hover, #custom-keys:hover {
        background-color: #2f354f;
        border-color: #7aa2f7;
        color: #7aa2f7;
    }

    #tray {
        background-color: rgba(26, 27, 38, 0.7);
        border: 1px solid rgba(41, 46, 66, 0.8);
        border-radius: 8px;
        padding: 2px 8px;
        margin: 4px 2px;
    }

    #custom-power {
        background: linear-gradient(135deg, rgba(247, 118, 142, 0.25) 0%, rgba(219, 75, 75, 0.35) 100%);
        border: 1px solid rgba(247, 118, 142, 0.5);
        border-radius: 8px;
        padding: 2px 8px;
        margin: 4px 8px 4px 2px;
        color: #f7768e;
        font-weight: 900;
    }

    #custom-power:hover {
        background: linear-gradient(135deg, #f7768e 0%, #db4b4b 100%);
        color: #14161f;
    }
  '';
}
