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
        exec ${pkgs.thunar}/bin/thunar "$SCREENSHOT_DIR"
        ;;
      *)
        exec ${pkgs.flameshot}/bin/flameshot gui
        ;;
    esac
  '';

  # Nix-packaged version of ~/.local/bin/hypr-clipboard
  hypr-clipboard = pkgs.writeShellScriptBin "hypr-clipboard" ''
    selected=$(${pkgs.cliphist}/bin/cliphist list 2>/dev/null | ${pkgs.rofi}/bin/rofi -dmenu -p "Clipboard" 2>/dev/null)
    if [ -n "$selected" ]; then
      if [ -n "$WAYLAND_DISPLAY" ]; then
        printf "%s" "$selected" | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
      else
        printf "%s" "$selected" | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.xclip}/bin/xclip -selection clipboard
      fi
    fi
  '';

  # Omarchy-style minimal system/power menu via Rofi
  hypr-power-menu = pkgs.writeShellScriptBin "hypr-power-menu" ''
    choice=$(printf "󰌾  Lock\n󰤄  Suspend\n󰜉  Reboot\n󰐥  Shutdown\n󰍃  Log out" \
      | ${pkgs.rofi}/bin/rofi -dmenu -i -p "System" -theme-str 'window { width: 320px; height: 270px; }')
    case "$choice" in
      *Lock*)     exec ${pkgs.hyprlock}/bin/hyprlock ;;
      *Suspend*)  exec systemctl suspend ;;
      *Reboot*)   exec systemctl reboot ;;
      *Shutdown*) exec systemctl poweroff ;;
      *Log\ out*) exec hyprctl dispatch exit ;;
    esac
  '';

  # Omarchy-style pop-out window (float + pin + reasonable size)
  hypr-pop-window = pkgs.writeShellScriptBin "hypr-pop-window" ''
    hyprctl dispatch togglefloating active
    hyprctl dispatch pin active
  '';
in
{
  imports = [
    ./waybar.nix
    ./rofi.nix
    ./kitty.nix
    ./dunst.nix
    ./hyprlock.nix
    ./keybinds-bg.nix
  ];

  # Companion packages for the Omarchy-esque Tokyo Night Hyprland desktop
  home.packages = with pkgs; [
    kitty
    waybar
    rofi
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
    thunar
    nerd-fonts.jetbrains-mono
    hypr-screenshot
    hypr-clipboard
    hypr-power-menu
    hypr-pop-window
  ];

  # ===========================================================================
  # HYPRLAND (Omarchy-esque Tokyo Night Config)
  # ===========================================================================
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;

    settings = {
      # ---- MONITORS ----
      monitor = [
        "HDMI-A-1, 1920x1080@100, 0x0, 1"
        "DP-2, 1920x1080@100, 1920x0, 1"
        "DP-1, 1920x1080@100, 1920x0, 1"
        "Virtual-1, preferred, auto, 1"
        ", preferred, auto, 1"
      ];

      workspace = [
        "1, default:true"
      ];

      # ---- ENVIRONMENT VARIABLES ----
      env = [
        "AQ_NO_ATOMIC,1"
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
        "QT_ICON_THEME,Colloid-Dark"
        "WLR_NO_HARDWARE_CURSORS,1"
        "HYPRLAND_NO_SD_NOTIFY,1"
      ];

      # ---- AUTOSTART ----
      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "gnome-keyring-daemon --start --components=secrets"
        "nm-applet"
        "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
        "wl-paste --type text --watch cliphist store"
        "spice-vdagent"
        "swww-daemon"
        "sh -c 'sleep 0.5 && swww img ~/Pictures/Wallpapers/default.png'"
        "waybar"
        "dunst"
        "toggle-keybinds-bg --start"
        "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"
        "gsettings set org.gnome.desktop.interface icon-theme 'Colloid-Dark'"
      ];

      # ---- LOOK AND FEEL (Omarchy-esque Tokyo Night) ----
      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        "col.active_border" = "rgba(7aa2f7ee) rgba(bb9af7ee) 45deg";
        "col.inactive_border" = "rgba(414868aa)";
        resize_on_border = true;
        extend_border_grab_area = 8;
        hover_icon_on_border = true;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 8;
        active_opacity = 1.0;
        inactive_opacity = 1.0;

        shadow = {
          enabled = true;
          range = 14;
          render_power = 3;
          color = "rgba(00000055)";
        };

        blur = {
          enabled = false;
        };
      };

      # Omarchy's snappy animation curves & instant workspace switching
      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint, 0.23, 1, 0.32, 1"
          "easeInOutCubic, 0.65, 0.05, 0.36, 1"
          "linear, 0, 0, 1, 1"
          "almostLinear, 0.5, 0.5, 0.75, 1.0"
          "quick, 0.15, 0, 0.1, 1"
        ];
        animation = [
          "global, 1, 8, default"
          "border, 1, 4.31, easeOutQuint"
          "windows, 1, 3.03, easeOutQuint"
          "windowsIn, 1, 3.28, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.19, linear, popin 87%"
          "fadeIn, 1, 1.38, almostLinear"
          "fadeOut, 1, 1.17, almostLinear"
          "fade, 1, 2.42, quick"
          "fadeSwitch, 0"
          "layers, 1, 3.05, easeOutQuint"
          "layersIn, 1, 3.2, easeOutQuint, fade"
          "layersOut, 1, 1.2, linear, fade"
          "fadeLayersIn, 1, 1.43, almostLinear"
          "fadeLayersOut, 1, 1.11, almostLinear"
          "workspaces, 0"
        ];
      };

      # ---- INPUT & LAYOUTS ----
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        repeat_rate = 40;
        repeat_delay = 250;
        numlock_by_default = true;

        touchpad = {
          natural_scroll = false;
          clickfinger_behavior = true;
        };
      };

      cursor = {
        no_hardware_cursors = true;
        hide_on_key_press = true;
        warp_on_change_workspace = 1;
      };

      gesture = [
        "3, horizontal, workspace"
      ];

      dwindle = {
        preserve_split = true;
        force_split = 2;
      };

      master = {
        new_status = "master";
      };

      binds = {
        hide_special_on_workspace_change = true;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        background_color = "rgb(1a1b26)";
        focus_on_activate = true;
        disable_watchdog_warning = true;
        disable_hyprland_guiutils_check = true;
      };

      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };

      # ---- WINDOW & LAYER RULES (Hyprland 0.53+ syntax) ----
      windowrule = [
        "suppress_event maximize, match:class .*"
        "no_focus on, match:class ^$, match:title ^$, match:xwayland 1, match:float 1, match:fullscreen 0, match:pin 0"
        "no_follow_mouse on, match:class ^(resolve)$"
        "float on, match:class ^(hyprland-run)$"
        "move 20 monitor_h-120, match:class ^(hyprland-run)$"
        "float on, size 760 520, center on, match:class .*pavucontrol.*"
        "float on, size 950 660, center on, match:class ^(?:.*hypr-?settings.*|io\\.github\\.hyprsettings)$"
        "float on, size 860 600, center on, match:class ^(hyprfrost-welcome)$"
      ];

      layerrule = [
        "no_anim on, match:namespace ^(waybar|conky-keybinds-bg)$"
      ];

      # ---- KEYBINDS (Omarchy-aligned) ----
      "$mainMod" = "SUPER";

      bind = [
        # Core App Binds
        "$mainMod, RETURN, exec, kitty"
        "$mainMod, B, exec, brave"
        "$mainMod, E, exec, thunar"
        "$mainMod, C, killactive,"
        "$mainMod, W, killactive,"
        "$mainMod SHIFT, D, exec, discord"
        "$mainMod SHIFT, ESCAPE, exec, kitty -e btop"

        # App Launcher & System Menus
        ", F24, exec, rofi -show drun"
        "$mainMod, space, exec, rofi -show drun"
        "$mainMod, R, exec, rofi -show drun"
        "$mainMod, D, exec, rofi -show drun"
        "$mainMod, Q, exec, hypr-power-menu"
        "$mainMod, K, exec, toggle-keybinds-bg"

        # System Management
        "$mainMod SHIFT, R, exec, sh -c 'hyprctl reload && pkill waybar; waybar &'"
        "$mainMod CONTROL, L, exec, hyprlock"
        "$mainMod SHIFT, V, exec, hypr-clipboard"

        # Screenshot Utility (Flameshot wrapper)
        ", Print, exec, hypr-screenshot"
        "SHIFT, Print, exec, hypr-screenshot full"
        "$mainMod, Print, exec, hypr-screenshot"
        "$mainMod SHIFT, S, exec, hypr-screenshot"
        "$mainMod CONTROL, S, exec, hypr-screenshot config"

        # Window Management
        "$mainMod, V, togglefloating,"
        "$mainMod, O, exec, hypr-pop-window"
        "$mainMod, F, fullscreen, 0"
        "$mainMod, P, pseudo,"
        "$mainMod, J, togglesplit,"
        "$mainMod, TAB, focusmonitor, +1"

        # Move focus & swap windows
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod SHIFT, left, swapwindow, l"
        "$mainMod SHIFT, right, swapwindow, r"
        "$mainMod SHIFT, up, swapwindow, u"
        "$mainMod SHIFT, down, swapwindow, d"

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

        # Special Workspace (Scratchpad)
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
      ];

      binde = [
        "$mainMod, equal, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        "$mainMod, minus, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];
    };
  };
}
