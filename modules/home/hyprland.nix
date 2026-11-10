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
  imports = [
    ./waybar.nix
    ./rofi.nix
    ./kitty.nix
    ./dunst.nix
    ./hyprlock.nix
  ];

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
}
