{ ... }:

{
  # ===========================================================================
  # WAYBAR (Omarchy-esque Minimal Solid Tokyo Night Top Bar)
  # ===========================================================================
  home.file.".config/waybar/config.jsonc".text = ''
    [
        {
            "name": "top-bar",
            "layer": "top",
            "position": "top",
            "height": 28,
            "margin-top": 0,
            "margin-left": 0,
            "margin-right": 0,
            "spacing": 0,
            "modules-left": [
                "custom/brand",
                "hyprland/workspaces"
            ],
            "modules-center": [
                "clock"
            ],
            "modules-right": [
                "custom/keys",
                "custom/clipboard",
                "custom/snip",
                "cpu",
                "memory",
                "wireplumber",
                "network",
                "tray",
                "custom/power"
            ],
            "custom/brand": {
                "format": "󱄅",
                "tooltip-format": "Apps (Super + Space)",
                "on-click": "rofi -show drun"
            },
            "hyprland/workspaces": {
                "disable-scroll": false,
                "all-outputs": false,
                "format": "{name}",
                "on-click": "activate",
                "persistent-workspaces": {
                    "1": [],
                    "2": [],
                    "3": [],
                    "4": [],
                    "5": []
                }
            },
            "clock": {
                "format": "{:%A %H:%M}",
                "format-alt": "{:%a, %b %d  %I:%M %p}",
                "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
            },
            "custom/keys": {
                "format": "󰌌",
                "tooltip-format": "Toggle Keybindings (Super + K)",
                "on-click": "toggle-keybinds-bg"
            },
            "custom/clipboard": {
                "format": "󰅍",
                "tooltip-format": "Clipboard History (Super + Shift + V)",
                "on-click": "hypr-clipboard"
            },
            "custom/snip": {
                "format": "󰄀",
                "tooltip-format": "Screenshot (Super + Shift + S)",
                "on-click": "hypr-screenshot",
                "on-click-right": "hypr-screenshot config"
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
                "tooltip-format": "{used:0.1f}G / {total:0.1f}G",
                "on-click": "kitty -e btop"
            },
            "wireplumber": {
                "format": "{icon} {volume}%",
                "format-muted": "󰝟",
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
                "icon-size": 15,
                "spacing": 8
            },
            "custom/power": {
                "format": "⏻",
                "tooltip-format": "Power Menu (Super + Q)",
                "on-click": "hypr-power-menu"
            }
        }
    ]
  '';

  home.file.".config/waybar/style.css".text = ''
    * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 12px;
        font-weight: 600;
        color: #c0caf5;
        min-height: 0;
    }

    window#waybar {
        background-color: #1a1b26;
        border-bottom: 1px solid #292e42;
    }

    #custom-brand {
        color: #7aa2f7;
        font-size: 14px;
        padding: 0 12px 0 14px;
    }

    #custom-brand:hover {
        background-color: #24283b;
    }

    #workspaces {
        margin: 0 4px;
    }

    #workspaces button {
        background: transparent;
        color: #565f89;
        padding: 0 8px;
        margin: 0 1px;
        border-bottom: 2px solid transparent;
        transition: color 0.15s ease, background-color 0.15s ease;
    }

    #workspaces button:hover {
        background-color: #24283b;
        color: #c0caf5;
    }

    #workspaces button.active {
        color: #7aa2f7;
        border-bottom: 2px solid #7aa2f7;
    }

    #workspaces button.urgent {
        color: #f7768e;
        border-bottom: 2px solid #f7768e;
    }

    #clock {
        color: #c0caf5;
        font-weight: 700;
        padding: 0 12px;
    }

    #clock:hover {
        background-color: #24283b;
        color: #7aa2f7;
    }

    #custom-keys,
    #custom-clipboard,
    #custom-snip,
    #cpu,
    #memory,
    #wireplumber,
    #network,
    #tray,
    #custom-power {
        background: transparent;
        padding: 0 9px;
        color: #a9b1d6;
    }

    #custom-keys:hover,
    #custom-clipboard:hover,
    #custom-snip:hover,
    #cpu:hover,
    #memory:hover,
    #wireplumber:hover,
    #network:hover {
        background-color: #24283b;
        color: #c0caf5;
    }

    #wireplumber.muted {
        color: #565f89;
    }

    #network.disconnected {
        color: #f7768e;
    }

    #custom-power {
        color: #f7768e;
        padding: 0 14px 0 10px;
    }

    #custom-power:hover {
        background-color: #24283b;
        color: #ff7a93;
    }

    tooltip {
        background-color: #1a1b26;
        border: 1px solid #7aa2f7;
        border-radius: 6px;
        color: #c0caf5;
    }
  '';
}
