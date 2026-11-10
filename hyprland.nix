{ config, pkgs, lib, ... }:

let
  # Nix-packaged version of ~/.local/bin/hypr-screenshot
  hypr-screenshot = pkgs.writeShellScriptBin "hypr-screenshot" ''
    if [ -n "$WAYLAND_DISPLAY" ]; then
      export XDG_CURRENT_DESKTOP="sway"
      export QT_QPA_PLATFORM="wayland;xcb"
    fi

    SCREENSHOT_DIR="''${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
    mkdir -p "$SCREENSHOT_DIR"

    case "''${1:-}" in
      full|screen)
        exec ${pkgs.flameshot}/bin/flameshot full -c -p "$SCREENSHOT_DIR"
        ;;
      config|settings)
        exec ${pkgs.flameshot}/bin/flameshot config
        ;;
      folder)
        exec ${pkgs.xfce.thunar}/bin/thunar "$SCREENSHOT_DIR"
        ;;
      *)
        exec ${pkgs.flameshot}/bin/flameshot gui
        ;;
    esac
  '';

  # Nix-packaged version of ~/.local/bin/hypr-clipboard
  hypr-clipboard = pkgs.writeShellScriptBin "hypr-clipboard" ''
    selected=$(${pkgs.cliphist}/bin/cliphist list 2>/dev/null | ${pkgs.rofi-wayland}/bin/rofi -dmenu -p "Clipboard" 2>/dev/null)
    if [ -n "$selected" ]; then
      if [ -n "$WAYLAND_DISPLAY" ]; then
        printf "%s" "$selected" | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
      else
        printf "%s" "$selected" | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.xclip}/bin/xclip -selection clipboard
      fi
    fi
  '';
in
{
  # Companion packages for the HyprFrost / Tokyo Night Hyprland desktop
  home.packages = with pkgs; [
    kitty
    waybar
    rofi-wayland
    dunst
    libnotify
    swww
    hyprpaper
    hyprlock
    hyprpolkitagent
    cliphist
    wl-clipboard
    xclip
    flameshot
    grim
    slurp
    swappy
    pavucontrol
    networkmanagerapplet
    gnome-keyring
    btop
    xfce.thunar
    nerd-fonts.jetbrains-mono
    hypr-screenshot
    hypr-clipboard
  ];

  # ===========================================================================
  # HYPRLAND (Native Home Manager Module)
  # ===========================================================================
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;

    settings = {
      # ---- MONITORS ----
      monitor = [
        "HDMI-A-1, 1920x1080@60, 0x0, 1"
        "DP-1, 1920x1080@60, 1920x0, 1"
        ", preferred, auto, 1"
      ];

      workspace = [
        "1, monitor:HDMI-A-1"
        "2, monitor:HDMI-A-1"
        "3, monitor:HDMI-A-1"
        "4, monitor:HDMI-A-1"
        "5, monitor:HDMI-A-1"
        "6, monitor:DP-1"
        "7, monitor:DP-1"
        "8, monitor:DP-1"
        "9, monitor:DP-1"
        "10, monitor:DP-1"
      ];

      # ---- ENVIRONMENT VARIABLES ----
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "GDK_BACKEND,wayland,x11,*"
        "SDL_VIDEODRIVER,wayland"
        "CLUTTER_BACKEND,wayland"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_QPA_PLATFORMTHEME,qt5ct;qt6ct"
        "WLR_NO_HARDWARE_CURSORS,0"
        "HYPRLAND_NO_SD_NOTIFY,1"
      ];

      # ---- AUTOSTART ----
      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "gnome-keyring-daemon --start --components=secrets"
        "nm-applet"
        "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
        "wl-paste --type text --watch cliphist store"
        "swww-daemon || hyprpaper"
        "sleep 0.5 && (swww restore || swww img ~/Pictures/Wallpapers/default.png || true)"
        "waybar"
        "dunst"
        "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"
        "gsettings set org.gnome.desktop.interface gtk-theme 'Tokyonight-Dark'"
      ];

      # ---- LOOK AND FEEL ----
      general = {
        gaps_in = 2;
        gaps_out = 5;
        border_size = 2;
        "col.active_border" = "rgba(7aa2f7ee) rgba(bb9af7ee) 45deg";
        "col.inactive_border" = "rgba(3b4261aa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 0.9;

        shadow = {
          enabled = true;
          range = 10;
          render_power = 3;
          color = "rgba(00000066)";
        };

        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          vibrancy = 0.1696;
          new_optimizations = true;
          xray = true;
        };
      };

      animations = {
        enabled = true;
      };

      # ---- INPUT & LAYOUTS ----
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;

        touchpad = {
          natural_scroll = false;
        };
      };

      cursor = {
        no_hardware_cursors = true;
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
      };

      dwindle = {
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        disable_watchdog_warning = true;
        disable_hyprland_guiutils_check = true;
      };

      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };

      # ---- WINDOW & LAYER RULES ----
      windowrulev2 = [
        "suppressevent maximize, class:.*"
        "nofocus, class:^$, title:^$, xwayland:1, floating:1, fullscreen:0, pinned:0"
        "float, class:^(hyprland-run)$"
        "move 20 100%-120, class:^(hyprland-run)$"
        "float, class:^(.*hypr-?settings.*|io\\.github\\.hyprsettings)$"
        "size 950 660, class:^(.*hypr-?settings.*|io\\.github\\.hyprsettings)$"
        "center, class:^(.*hypr-?settings.*|io\\.github\\.hyprsettings)$"
        "float, class:^(hyprfrost-welcome)$"
        "size 860 600, class:^(hyprfrost-welcome)$"
        "center, class:^(hyprfrost-welcome)$"
      ];

      layerrule = [
        "blur, jacob-(topbar|dock|launcher|clipboard|power|calendar|notifications|toast|media|keybinds|welcome|contextmenu|appcontextmenu|taskbarmenu)"
        "ignorealpha 0.25, jacob-(topbar|dock|launcher|clipboard|power|calendar|notifications|toast|media|keybinds|welcome|contextmenu|appcontextmenu|taskbarmenu)"
        "noanim, jacob-topbar"
        "noanim, jacob-dock"
      ];

      # ---- KEYBINDS ----
      "$mainMod" = "SUPER";

      bind = [
        # Core App Binds
        "$mainMod, RETURN, exec, kitty"
        "$mainMod, E, exec, thunar"
        "$mainMod, B, exec, brave"
        "$mainMod, C, killactive,"
        "$mainMod SHIFT, D, exec, discord"

        # App Launcher
        ", F24, exec, rofi -show drun"
        "$mainMod, space, exec, rofi -show drun"
        "$mainMod, R, exec, rofi -show drun"
        "$mainMod, D, exec, rofi -show drun"

        # System Management
        "$mainMod SHIFT, R, exec, sh -c 'hyprctl reload && pkill waybar; waybar &'"
        "$mainMod, L, exec, hyprlock"

        # Screenshot Utility (Flameshot wrapper)
        ", Print, exec, hypr-screenshot"
        "SHIFT, Print, exec, hypr-screenshot full"
        "$mainMod, Print, exec, hypr-screenshot"
        "$mainMod SHIFT, S, exec, hypr-screenshot"
        "$mainMod CONTROL, S, exec, hypr-screenshot config"

        # Window Management
        "$mainMod, V, togglefloating,"
        "$mainMod, F, fullscreen, 0"
        "$mainMod, P, pseudo,"
        "$mainMod, J, togglesplit,"
        "$mainMod, TAB, focusmonitor, +1"

        # Move focus
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Workspaces 1-10
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move active window to workspace 1-10
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Special Workspace
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod ALT, S, movetoworkspace, special:magic"

        # Audio Mute
        "$mainMod, BackSpace, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];

      bindr = [
        "SUPER, Super_L, exec, rofi -show drun"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
        ", mouse:274, movewindow"
        "$mainMod, mouse:274, movewindow"
      ];

      binde = [
        "$mainMod, equal, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        "$mainMod, minus, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];
    };
  };

  # ===========================================================================
  # HYPRPAPER
  # ===========================================================================
  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ~/Pictures/Wallpapers/default.png
    wallpaper = HDMI-A-1,~/Pictures/Wallpapers/default.png
    wallpaper = DP-1,~/Pictures/Wallpapers/default.png
    wallpaper = ,~/Pictures/Wallpapers/default.png
    splash = false
  '';

  # ===========================================================================
  # HYPRLOCK (Tokyo Night Theme)
  # ===========================================================================
  home.file.".config/hypr/hyprlock.conf".text = ''
    general {
        disable_loading_bar = false
        hide_cursor = false
        grace = 0
        no_fade_in = false
    }

    animations {
        enabled = true
        bezier = linear, 1, 1, 0, 0
        animation = fadeIn, 1, 3, linear
        animation = fadeOut, 1, 3, linear
        animation = inputFieldDots, 1, 2, linear
    }

    background {
        monitor =
        path = ~/Pictures/Wallpapers/default.png
        color = rgba(26, 27, 38, 1.0)
        blur_passes = 3
        blur_size = 6
        noise = 0.0117
        contrast = 0.8916
        brightness = 0.8172
        vibrancy = 0.1696
        vibrancy_darkness = 0.05
    }

    # Time (12-hour AM/PM)
    label {
        monitor =
        text = cmd[update:1000] echo "$(date +"%I:%M %p")"
        color = rgb(192, 202, 245)
        font_size = 64
        font_family = JetBrains Mono, JetBrainsMono Nerd Font, monospace
        position = 0, 240
        halign = center
        valign = center
        shadow_passes = 2
        shadow_size = 6
        shadow_color = rgba(0, 0, 0, 0.45)
    }

    # Date
    label {
        monitor =
        text = cmd[update:1000] echo "$(date +"%A, %B %d, %Y")"
        color = rgb(122, 162, 247)
        font_size = 18
        font_family = JetBrains Mono, JetBrainsMono Nerd Font, monospace
        position = 0, 170
        halign = center
        valign = center
        shadow_passes = 1
        shadow_size = 4
        shadow_color = rgba(0, 0, 0, 0.4)
    }

    # User Greeting
    label {
        monitor =
        text = Hi, $USER
        color = rgba(192, 202, 245, 0.9)
        font_size = 16
        font_family = JetBrains Mono, JetBrainsMono Nerd Font, monospace
        position = 0, 0
        halign = center
        valign = center
        shadow_passes = 1
        shadow_size = 4
        shadow_color = rgba(0, 0, 0, 0.4)
    }

    # Password Input Field
    input-field {
        monitor =
        size = 280, 48
        outline_thickness = 2
        dots_size = 0.22
        dots_spacing = 0.2
        dots_center = true
        dots_rounding = -1
        fade_on_empty = false
        placeholder_text = <i><span foreground="##565f89">󰌾  Enter password...</span></i>
        hide_input = false
        rounding = 12
        position = 0, -65
        halign = center
        valign = center

        inner_color = rgba(26, 27, 38, 0.85)
        outer_color = rgba(122, 162, 247, 0.9) rgba(187, 154, 247, 0.9) 45deg
        check_color = rgba(122, 162, 247, 0.9) rgba(125, 207, 255, 0.9) 120deg
        fail_color = rgba(247, 118, 142, 0.9) rgba(255, 117, 127, 0.9) 40deg
        capslock_color = rgba(224, 175, 104, 0.9)
        font_color = rgb(192, 202, 245)
        fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>

        shadow_passes = 2
        shadow_size = 8
        shadow_color = rgba(0, 0, 0, 0.45)
    }

    # Bottom Status / Hint
    label {
        monitor =
        text = 󰌾 Locked
        color = rgba(86, 95, 137, 0.7)
        font_size = 11
        font_family = JetBrains Mono, JetBrainsMono Nerd Font, monospace
        position = 0, 25
        halign = center
        valign = bottom
    }
  '';

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

  # ===========================================================================
  # ROFI (Tokyo Night Launcher)
  # ===========================================================================
  home.file.".config/rofi/config.rasi".text = ''
    configuration {
        modes:                      [ drun, run ];
        show-icons:                 true;
        display-drun:               " 󱄅  Launcher ";
        display-run:                "   Run ";
        drun-display-format:        "{name}";
        font:                       "JetBrainsMono Nerd Font 11";
    }

    @theme "~/.config/rofi/theme.rasi"
  '';

  home.file.".config/rofi/theme.rasi".text = ''
    * {
        bg:                         rgba ( 20, 21, 32, 85 % );
        bg-alt:                     #161722;
        bg-selected:                #283457;
        fg:                         #c0caf5;
        fg-dim:                     #565f89;
        blue:                       #7aa2f7;
        purple:                     #bb9af7;
        cyan:                       #7dcfff;
        border-col:                 rgba ( 122, 162, 247, 70 % );
        border-subtle:              #3b4261;

        background-color:           transparent;
        text-color:                 var(fg);
        margin:                     0;
        padding:                    0;
    }

    window {
        transparency:               "real";
        location:                   center;
        anchor:                     center;
        fullscreen:                 false;
        width:                      560px;
        height:                     480px;
        enabled:                    true;
        border-radius:              14px;
        border:                     2px;
        border-color:               var(border-col);
        background-color:           var(bg);
        cursor:                     "default";
    }

    mainbox {
        enabled:                    true;
        spacing:                    12px;
        padding:                    18px;
        orientation:                vertical;
        children:                   [ "inputbar", "listview" ];
        background-color:           transparent;
    }

    inputbar {
        enabled:                    true;
        spacing:                    10px;
        padding:                    8px 14px;
        border-radius:              8px;
        border:                     1px;
        border-color:               var(border-subtle);
        background-color:           var(bg-alt);
        text-color:                 var(fg);
        children:                   [ "prompt", "entry" ];
    }

    prompt {
        enabled:                    true;
        background-color:           inherit;
        text-color:                 var(blue);
        font:                       "JetBrainsMono Nerd Font Bold 11";
    }

    entry {
        enabled:                    true;
        background-color:           inherit;
        text-color:                 #ffffff;
        cursor:                     text;
        placeholder:                "Search applications...";
        placeholder-color:          var(fg-dim);
    }

    listview {
        enabled:                    true;
        columns:                    1;
        lines:                      8;
        cycle:                      true;
        dynamic:                    true;
        scrollbar:                  false;
        layout:                     vertical;
        reverse:                    false;
        fixed-height:               true;
        fixed-columns:              true;
        spacing:                    6px;
        background-color:           transparent;
    }

    element {
        enabled:                    true;
        spacing:                    12px;
        padding:                    8px 12px;
        border-radius:              8px;
        background-color:           transparent;
        text-color:                 var(fg);
        cursor:                     pointer;
        border:                     1px;
        border-color:               transparent;
    }

    element selected.normal {
        background-color:           var(bg-selected);
        text-color:                 var(blue);
        border-color:               var(blue);
    }

    element-icon {
        background-color:           transparent;
        text-color:                 inherit;
        size:                       26px;
        cursor:                     inherit;
    }

    element-text {
        background-color:           transparent;
        text-color:                 inherit;
        cursor:                     inherit;
        vertical-align:             0.5;
        horizontal-align:           0.0;
    }
  '';

  # ===========================================================================
  # KITTY (Tokyo Night Terminal)
  # ===========================================================================
  home.file.".config/kitty/kitty.conf".text = ''
    # TokyoNight Kitty Configuration
    font_family      JetBrainsMono Nerd Font
    bold_font        auto
    italic_font      auto
    bold_italic_font auto
    font_size        11.0

    window_padding_width 12
    confirm_os_window_close 0
    enable_audio_bell no

    cursor_shape beam
    cursor_blink_interval 0

    background_opacity 0.80
    dynamic_background_opacity yes

    # TokyoNight Color Palette
    foreground #c0caf5
    background #1a1b26
    selection_foreground #c0caf5
    selection_background #33467c

    cursor #c0caf5
    cursor_text_color #1a1b26

    url_color #73daca

    active_border_color #7aa2f7
    inactive_border_color #292e42

    color0  #15161e
    color8  #414868
    color1  #f7768e
    color9  #f7768e
    color2  #9ece6a
    color10 #9ece6a
    color3  #e0af68
    color11 #e0af68
    color4  #7aa2f7
    color12 #7aa2f7
    color5  #bb9af7
    color13 #bb9af7
    color6  #7dcfff
    color14 #7dcfff
    color7  #a9b1d6
    color15 #c0caf5
  '';

  # ===========================================================================
  # DUNST (Tokyo Night Notifications)
  # ===========================================================================
  home.file.".config/dunst/dunstrc".text = ''
    [global]
        monitor = 0
        follow = mouse
        origin = top-right
        offset = (16, 48)
        width = 360
        height = (0, 300)
        indicate_hidden = yes
        transparency = 10
        separator_height = 2
        padding = 12
        horizontal_padding = 14
        text_icon_padding = 12
        frame_width = 2
        frame_color = "#3b4261"
        separator_color = frame
        sort = yes
        idle_threshold = 120
        font = JetBrainsMono Nerd Font 10
        line_height = 0
        markup = full
        format = "<b>%s</b>\n%b"
        alignment = left
        show_age_threshold = 60
        word_wrap = yes
        ellipsize = middle
        ignore_newline = no
        stack_duplicates = true
        hide_duplicate_count = false
        show_indicators = yes
        icon_position = left
        min_icon_size = 24
        max_icon_size = 48
        corner_radius = 10
        mouse_left_click = close_current
        mouse_middle_click = do_action, close_current
        mouse_right_click = close_all

    [urgency_low]
        background = "#141622"
        foreground = "#a9b1d6"
        frame_color = "#414868"
        timeout = 4

    [urgency_normal]
        background = "#141622"
        foreground = "#c0caf5"
        frame_color = "#7aa2f7"
        timeout = 6

    [urgency_critical]
        background = "#141622"
        foreground = "#f7768e"
        frame_color = "#f7768e"
        timeout = 0
  '';
}
