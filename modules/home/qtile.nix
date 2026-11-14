{ pkgs, ... }:

{
  home.packages = with pkgs; [
    picom
    papirus-icon-theme
    xrandr
  ];

  # ===========================================================================
  # QTILE CONFIGURATION (~/.config/qtile/config.py)
  # ===========================================================================
  home.file.".config/qtile/config.py".text = ''
    # =============================================================================
    # HyprFrost / NixOS Native Qtile Configuration
    # 100% Cross-Compatible, Self-Contained Native Python Desktop
    # Matching Exact Jacob Shell Aesthetics (Tokyo Night Glass Floating Bars)
    # =============================================================================

    import html
    import os
    import re
    import subprocess
    import types
    from libqtile import bar, hook, layout, widget
    from libqtile.config import Click, Drag, Group, Key, Match, Screen
    from libqtile.lazy import lazy

    # ---------------------------------------------
    # ---- WAYLAND & ENVIRONMENT OPTIMIZATIONS ----
    # ---------------------------------------------
    os.environ["WLR_NO_HARDWARE_CURSORS"] = "1"
    os.environ["XCURSOR_SIZE"] = "24"
    os.environ["QT_QPA_PLATFORM"] = "wayland;xcb"
    os.environ["GDK_BACKEND"] = "wayland,x11,*"

    # ----------------------------
    # ---- MODIFIER & APPS -------
    # ----------------------------
    mod = "mod4"  # Super / Windows key
    terminal = "kitty"
    file_manager = "thunar"
    browser = "brave"
    wallpaper_path = os.path.expanduser("~/Pictures/Wallpapers/default.png")

    # -----------------------------------------------
    # ---- TOKYO NIGHT FROSTED PALETTE --------------
    # -----------------------------------------------
    colors = {
        "bar_bg": "#141622e6",        # rgba(20, 22, 34, 0.90) deep glass
        "bg_alt": "#1f2335",          # Slightly lighter pill surface
        "pill_bg": "#1a1b26",         # Standard pill container background
        "pill_border": "#292e42",     # Subtle dark pill border
        "fg": "#c0caf5",              # Primary text
        "fg_dim": "#565f89",          # Dim / muted text
        "blue": "#7aa2f7",            # Tokyo Night blue accent
        "purple": "#bb9af7",          # Purple accent
        "cyan": "#7dcfff",            # Cyan accent
        "green": "#9ece6a",           # Green accent
        "yellow": "#e0af68",          # Yellow
        "red": "#f7768e",             # Red / Warning
        "border_active": "#7aa2f7",
        "border_inactive": "#3b4261",
        "bar_border": "#3b4261",
    }

    # ----------------------------------------
    # ---- WORKSPACES / GROUPS (1-10) --------
    # ----------------------------------------
    groups = [Group(str(i), label=str(i)) for i in range(1, 11)]

    def go_to_group(name):
        def _inner(qtile_inst):
            idx = int(name)
            target_screen = 0 if idx <= 5 else 1
            if len(qtile_inst.screens) > target_screen:
                qtile_inst.to_screen(target_screen)
            qtile_inst.groups_map[name].toscreen()
        return _inner

    def toggle_floating_or_tile(qtile_inst):
        win = qtile_inst.current_window
        if not win:
            return
        if win.fullscreen:
            win.fullscreen = False
            win.floating = True
        else:
            win.toggle_floating()

    def toggle_fullscreen_clean(qtile_inst):
        win = qtile_inst.current_window
        if not win:
            return
        if win.fullscreen:
            win.fullscreen = False
            win.floating = False
        else:
            win.fullscreen = True

    def cycle_all_screens_layout(qtile_inst):
        """Cycle the layout on all active monitors simultaneously in sync."""
        if not qtile_inst.current_group or not qtile_inst.current_group.layouts:
            return
        target_idx = (qtile_inst.current_group.current_layout + 1) % len(qtile_inst.current_group.layouts)
        for screen in qtile_inst.screens:
            if screen.group:
                screen.group.use_layout(target_idx)

    # -----------------------------
    # ---- KEYBINDINGS ------------
    # -----------------------------
    keys = [
        # Application Launcher (Super tap via keyd F24, or Super+Space, Super+R, Super+D)
        Key([], "F24", lazy.spawn("rofi -show drun"), desc="Open Rofi app launcher with Super tap"),
        Key([mod], "space", lazy.spawn("rofi -show drun"), desc="Open Rofi app launcher"),
        Key([mod], "r", lazy.spawn("rofi -show drun"), desc="Open Rofi app launcher"),
        Key([mod], "d", lazy.spawn("rofi -show drun"), desc="Open Rofi app launcher"),

        # Core Applications (Matching Hyprland shortcuts)
        Key([mod], "Return", lazy.spawn(terminal), desc="Launch Kitty Terminal"),
        Key([mod], "e", lazy.spawn(file_manager), desc="Launch Thunar File Manager"),
        Key([mod], "b", lazy.spawn(browser), desc="Launch Brave Browser"),
        Key([mod, "shift"], "d", lazy.spawn("discord"), desc="Launch Discord"),
        Key([mod], "c", lazy.window.kill(), desc="Close focused window"),

        # Window State
        Key([mod], "v", lazy.function(toggle_floating_or_tile), desc="Toggle floating / tile window"),
        Key([mod], "f", lazy.function(toggle_fullscreen_clean), desc="Toggle fullscreen / tile"),
        Key([mod], "Tab", lazy.next_screen(), desc="Focus next monitor"),

        # Tiling Layout Controls
        Key([mod], "j", lazy.layout.toggle_split(), desc="Toggle split"),
        Key([mod, "control"], "space", lazy.function(cycle_all_screens_layout), desc="Cycle layout on all screens"),

        # Focus Movement (Matching Hyprland arrows)
        Key([mod], "Left", lazy.layout.left(), desc="Move focus left"),
        Key([mod], "Right", lazy.layout.right(), desc="Move focus right"),
        Key([mod], "Down", lazy.layout.down(), desc="Move focus down"),
        Key([mod], "Up", lazy.layout.up(), desc="Move focus up"),

        # Shuffle Windows
        Key([mod, "shift"], "Left", lazy.layout.shuffle_left(), desc="Shuffle window left"),
        Key([mod, "shift"], "Right", lazy.layout.shuffle_right(), desc="Shuffle window right"),
        Key([mod, "shift"], "Down", lazy.layout.shuffle_down(), desc="Shuffle window down"),
        Key([mod, "shift"], "Up", lazy.layout.shuffle_up(), desc="Shuffle window up"),

        # Resize Windows
        Key([mod, "control"], "Left", lazy.layout.grow_left(), desc="Grow window left"),
        Key([mod, "control"], "Right", lazy.layout.grow_right(), desc="Grow window right"),
        Key([mod, "control"], "Down", lazy.layout.grow_down(), desc="Grow window down"),
        Key([mod, "control"], "Up", lazy.layout.grow_up(), desc="Grow window up"),
        Key([mod, "control"], "n", lazy.layout.normalize(), desc="Reset window sizes"),

        # Volume & Media Keys (Universal PipeWire wpctl)
        Key([], "XF86AudioRaiseVolume", lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), desc="Volume up"),
        Key([], "XF86AudioLowerVolume", lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), desc="Volume down"),
        Key([], "XF86AudioMute", lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), desc="Mute volume"),
        Key([mod], "equal", lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), desc="Volume up"),
        Key([mod], "minus", lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), desc="Volume down"),
        Key([mod], "BackSpace", lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), desc="Mute volume"),

        # Screenshots (Flameshot wrapper)
        Key([], "Print", lazy.spawn("hypr-screenshot"), desc="Flameshot GUI"),
        Key(["shift"], "Print", lazy.spawn("hypr-screenshot full"), desc="Full screenshot"),
        Key([mod], "Print", lazy.spawn("hypr-screenshot"), desc="Flameshot GUI"),
        Key([mod, "shift"], "s", lazy.spawn("hypr-screenshot"), desc="Flameshot GUI"),
        Key([mod, "control"], "s", lazy.spawn("hypr-screenshot config"), desc="Flameshot config"),

        # Clipboard & Keybind Help
        Key([mod, "shift"], "v", lazy.spawn("hypr-clipboard"), desc="Clipboard history"),
        Key([mod], "k", lazy.spawn("notify-send 'Keybinds' 'Super+Return: Terminal\nSuper+Space: App Launcher\nSuper+E: Files\nSuper+B: Browser\nSuper+C: Close Window\nSuper+Shift+Q: Exit'"), desc="Show keybinds"),

        # Session Management
        Key([mod, "shift"], "r", lazy.reload_config(), desc="Reload Qtile Configuration"),
        Key([mod, "shift"], "q", lazy.shutdown(), desc="Logout / Exit Qtile"),
    ]

    # Map Workspaces 1-10 to keys
    for i in groups:
        key_name = "0" if i.name == "10" else i.name
        keys.extend([
            Key([mod], key_name, lazy.function(go_to_group(i.name)), desc=f"Switch to group {i.name}"),
            Key([mod, "shift"], key_name, lazy.window.togroup(i.name, switch_group=False),
                desc=f"Move window to group {i.name}"),
        ])

    # ---------------------------------------
    # ---- LAYOUTS (MATCHING HYPRLAND) ------
    # ---------------------------------------
    layout_theme = {
        "border_width": 2,
        "margin": 6,
        "border_focus": colors["border_active"],
        "border_normal": colors["border_inactive"],
    }

    layouts = [
        layout.Bsp(**layout_theme, border_on_single=True, fair=False),
        layout.Columns(**layout_theme, border_focus_stack=[colors["purple"], colors["blue"]], border_on_single=True),
        layout.Max(**layout_theme),
        layout.Floating(**layout_theme),
    ]

    # ------------------------------------------------
    # ---- TOP & BOTTOM BARS -------------------------
    # ------------------------------------------------
    def get_disk_status():
        import shutil
        try:
            total, used, free = shutil.disk_usage("/")
            pct = (used / total) * 100
            if free >= 10**12:
                val = f"{free / (1024**4):.1f}T"
            elif free >= 10**9:
                val = f"{free / (1024**3):.0f}G"
            else:
                val = f"{free / (1024**2):.0f}M"
            return f"{val} ({pct:.0f}%)"
        except Exception:
            return "? (0%)"

    def build_top_bar(screen_index=0):
        """
        Unified single top bar combining both top status and bottom dock launchers.
        """
        widgets = [
            # Left Margin
            widget.Sep(linewidth=0, padding=4),

            # 1. Start / Brand Launcher
            widget.TextBox(
                text="󰣇",
                foreground=colors["blue"],
                background=colors["bg_alt"],
                font="JetBrainsMono Nerd Font Bold",
                fontsize=12,
                padding=8,
                mouse_callbacks={"Button1": lazy.spawn("rofi -show drun")},
            ),
            widget.Sep(linewidth=0, padding=4),
            widget.TextBox(text="|", foreground=colors["fg_dim"], font="JetBrainsMono Nerd Font", padding=2, fontsize=12),

            # 2. Workspaces 1-10
            widget.GroupBox(
                font="JetBrainsMono Nerd Font Bold",
                fontsize=10,
                margin_y=3,
                margin_x=2,
                padding_y=3,
                padding_x=6,
                borderwidth=1,
                active=colors["blue"],
                inactive=colors["fg_dim"],
                rounded=True,
                highlight_color=[colors["bg_alt"], colors["bg_alt"]],
                highlight_method="block",
                this_current_screen_border=colors["border_active"],
                block_highlight_text_color=colors["bar_bg"],
                visible_groups=[str(n) for n in range(1, 11)],
                disable_drag=True,
            ),
            widget.TextBox(text="|", foreground=colors["fg_dim"], font="JetBrainsMono Nerd Font", padding=2, fontsize=12),

            # 3. Quick App Launchers (from bottom dock)
            widget.TextBox(
                text="󰞷",
                foreground=colors["fg"],
                background=colors["pill_bg"],
                font="JetBrainsMono Nerd Font",
                fontsize=11,
                padding=6,
                mouse_callbacks={"Button1": lazy.spawn("kitty")},
            ),
            widget.Sep(linewidth=0, padding=2),
            widget.TextBox(
                text="󰉋",
                foreground=colors["fg"],
                background=colors["pill_bg"],
                font="JetBrainsMono Nerd Font",
                fontsize=11,
                padding=6,
                mouse_callbacks={"Button1": lazy.spawn("thunar")},
            ),
            widget.Sep(linewidth=0, padding=2),
            widget.TextBox(
                text="󰈹",
                foreground=colors["fg"],
                background=colors["pill_bg"],
                font="JetBrainsMono Nerd Font",
                fontsize=11,
                padding=6,
                mouse_callbacks={"Button1": lazy.spawn("brave")},
            ),
            widget.TextBox(text="|", foreground=colors["fg_dim"], font="JetBrainsMono Nerd Font", padding=2, fontsize=12),

            # 4. Current Layout
            widget.CurrentLayout(
                foreground=colors["purple"],
                background=colors["pill_bg"],
                font="JetBrainsMono Nerd Font Bold",
                fontsize=10,
                padding=6,
            ),
            widget.TextBox(text="|", foreground=colors["fg_dim"], font="JetBrainsMono Nerd Font", padding=2, fontsize=12),

            # 5. Active Window Name
            widget.WindowName(
                foreground=colors["fg_dim"],
                font="JetBrainsMono Nerd Font",
                fontsize=10,
                padding=6,
                max_chars=25,
            ),

            # Center Expander Spacer
            widget.Spacer(),

            # 6. Center Date & Clock
            widget.TextBox(
                text="󰥔 ",
                foreground=colors["cyan"],
                background=colors["pill_bg"],
                font="JetBrainsMono Nerd Font Bold",
                fontsize=12,
                padding=4,
            ),
            widget.Clock(
                format="%a, %b %d • %I:%M %p",
                foreground=colors["cyan"],
                background=colors["pill_bg"],
                font="JetBrainsMono Nerd Font Bold",
                fontsize=10,
                padding=6,
                mouse_callbacks={"Button1": lazy.spawn("notify-send 'Calendar' \"$(cal)\"")},
            ),
            widget.Sep(linewidth=0, padding=4),

            # 7. Media Chip
            widget.TextBox(
                text="󰎆",
                foreground=colors["purple"],
                background=colors["pill_bg"],
                font="JetBrainsMono Nerd Font",
                fontsize=11,
                padding=6,
                mouse_callbacks={"Button1": lazy.spawn("pavucontrol")},
            ),

            # Right Expander Spacer
            widget.Spacer(),

            # 8. Utilities: Clipboard, Snip, Keys (from bottom dock)
            widget.TextBox(
                text="󰅍",
                foreground=colors["fg"],
                background=colors["pill_bg"],
                font="JetBrainsMono Nerd Font",
                fontsize=11,
                padding=6,
                mouse_callbacks={"Button1": lazy.spawn("/home/jacob/.local/bin/hypr-clipboard")},
            ),
            widget.Sep(linewidth=0, padding=2),
            widget.TextBox(
                text="󰄀",
                foreground=colors["fg"],
                background=colors["pill_bg"],
                font="JetBrainsMono Nerd Font",
                fontsize=11,
                padding=6,
                mouse_callbacks={
                    "Button1": lazy.spawn("/home/jacob/.local/bin/hypr-screenshot"),
                    "Button3": lazy.spawn("/home/jacob/.local/bin/hypr-screenshot config"),
                },
            ),
            widget.Sep(linewidth=0, padding=2),
            widget.TextBox(
                text="󰌌",
                foreground=colors["fg"],
                background=colors["pill_bg"],
                font="JetBrainsMono Nerd Font",
                fontsize=11,
                padding=6,
                mouse_callbacks={"Button1": lazy.spawn("notify-send 'Shortcuts' 'Super+Return: Terminal\nSuper+Space: App Launcher\nSuper+E: Files\nSuper+B: Browser\nSuper+C: Close Window'")},
            ),
            widget.Sep(linewidth=0, padding=4),

            # 9. Hardware & System Status Area
            # CPU
            widget.TextBox(
                text="󰻠",
                foreground=colors["blue"],
                background=colors["pill_bg"],
                font="JetBrainsMono Nerd Font",
                fontsize=11,
                padding=3,
                mouse_callbacks={"Button1": lazy.spawn("kitty -e btop")},
            ),
            widget.CPU(
                format="{load_percent}%",
                foreground=colors["fg"],
                background=colors["pill_bg"],
                font="JetBrainsMono Nerd Font",
                fontsize=10,
                padding=3,
                mouse_callbacks={"Button1": lazy.spawn("kitty -e btop")},
            ),
            widget.Sep(linewidth=0, padding=3),

            # Memory
            widget.TextBox(
                text="󰍛",
                foreground=colors["purple"],
                background=colors["pill_bg"],
                font="JetBrainsMono Nerd Font",
                fontsize=11,
                padding=3,
                mouse_callbacks={"Button1": lazy.spawn("kitty -e btop")},
            ),
            widget.Memory(
                measure_mem="G",
                format="{MemUsed:.1f}G ({MemPercent:.0f}%)",
                foreground=colors["fg"],
                background=colors["pill_bg"],
                font="JetBrainsMono Nerd Font",
                fontsize=10,
                padding=3,
                mouse_callbacks={"Button1": lazy.spawn("kitty -e btop")},
            ),
            widget.Sep(linewidth=0, padding=3),

            # Disk Free
            widget.TextBox(
                text="󰋊",
                foreground=colors["yellow"],
                background=colors["pill_bg"],
                font="JetBrainsMono Nerd Font",
                fontsize=11,
                padding=3,
                mouse_callbacks={"Button1": lazy.spawn("kitty -e btop")},
            ),
            widget.GenPollText(
                func=get_disk_status,
                update_interval=30,
                foreground=colors["fg"],
                background=colors["pill_bg"],
                font="JetBrainsMono Nerd Font",
                fontsize=10,
                padding=3,
                mouse_callbacks={"Button1": lazy.spawn("kitty -e btop")},
            ),
            widget.Sep(linewidth=0, padding=3),

            # Audio Volume
            widget.TextBox(text="", foreground=colors["green"], background=colors["pill_bg"], font="JetBrainsMono Nerd Font", fontsize=11, padding=3),
            widget.Volume(
                foreground=colors["fg"],
                background=colors["pill_bg"],
                font="JetBrainsMono Nerd Font",
                fontsize=10,
                padding=3,
                mouse_callbacks={"Button1": lazy.spawn("pavucontrol")},
            ),
            widget.Sep(linewidth=0, padding=3),
        ]

        # Ethernet icon
        widgets.extend([
            widget.Image(
                filename="${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/16x16/devices/network-wired.svg",
                margin=9,
                mouse_callbacks={"Button1": lazy.spawn("nm-connection-editor")},
            ),
            widget.Sep(linewidth=0, padding=3),
        ])

        # Power Button
        widgets.extend([
            widget.TextBox(
                text=" ⏻ ",
                foreground=colors["red"],
                background=colors["pill_bg"],
                font="JetBrainsMono Nerd Font Bold",
                fontsize=12,
                padding=5,
                mouse_callbacks={"Button1": lazy.shutdown()},
            ),
            widget.Sep(linewidth=0, padding=4),
        ])

        return bar.Bar(
            widgets,
            38,
            background=colors["bar_bg"],
            opacity=0.94,
            margin=[6, 12, 0, 12],
            border_width=[1, 1, 1, 1],
            border_color=colors["bar_border"],
        )

    # ------------------------------------------------
    # ---- SCREENS CONFIGURATION ---------------------
    # ------------------------------------------------
    screens = [
        Screen(
            top=build_top_bar(0),
            wallpaper=wallpaper_path if os.path.isfile(wallpaper_path) else None,
            wallpaper_mode="fill",
        ),
        Screen(
            top=build_top_bar(1),
            wallpaper=wallpaper_path if os.path.isfile(wallpaper_path) else None,
            wallpaper_mode="fill",
        ),
    ]

    # ----------------------------
    # ---- MOUSE INTERACTIONS ----
    # ----------------------------
    def setup_drag_snap(qtile_inst):
        if not qtile_inst or getattr(qtile_inst, "_drag_snap_installed", False):
            return

        orig_click = qtile_inst.process_button_click
        orig_release = qtile_inst.process_button_release
        orig_motion = qtile_inst.process_button_motion

        def patched_motion(self, x, y):
            handled = orig_motion(x, y)
            win = getattr(self, "_active_drag_window", None)
            if win:
                try:
                    win.bring_to_front()
                except Exception:
                    pass
            return handled

        def patched_click(self, button_code, modmask, x, y):
            win = self.current_window
            was_fs = False
            was_tiled = False
            if win:
                try:
                    win.bring_to_front()
                    win.focus(warp=False)
                except Exception:
                    pass

                if getattr(win, "fullscreen", False):
                    was_fs = True
                    win.fullscreen = False
                    win.floating = True
                elif not getattr(win, "floating", False):
                    was_tiled = True
                    win.floating = True

            handled = orig_click(button_code, modmask, x, y)
            if self._drag is not None and win:
                self._active_drag_window = win
                win._drag_was_fullscreen = was_fs
                win._drag_was_tiled = was_tiled
            elif self._drag is None and win:
                if was_fs:
                    win.fullscreen = True
                elif was_tiled:
                    win.floating = False
            return handled

        def patched_release(self, button_code, modmask):
            win = getattr(self, "_active_drag_window", None)
            was_drag = (self._drag is not None)
            handled = orig_release(button_code, modmask)
            if was_drag and win:
                self._active_drag_window = None
                try:
                    win.bring_to_front()
                    wm_classes = [c.lower() for c in (win.get_wm_class() or [])]
                    dialogs = {
                        "pavucontrol", "blueman-manager", "pinentry", "ssh-askpass",
                        "confirmreset", "makebranch", "maketag", "branchdialog",
                        "file_progress", "dialog", "download", "error", "notification"
                    }
                    if not any(d in wm_classes for d in dialogs):
                        is_game = any("hogwarts" in c or "steam_app" in c for c in wm_classes)
                        if getattr(win, "_drag_was_fullscreen", False) or is_game:
                            win.fullscreen = True
                            win.floating = False
                        else:
                            win.floating = False
                except Exception:
                    pass
            return handled

        qtile_inst.process_button_click = types.MethodType(patched_click, qtile_inst)
        qtile_inst.process_button_release = types.MethodType(patched_release, qtile_inst)
        qtile_inst.process_button_motion = types.MethodType(patched_motion, qtile_inst)
        qtile_inst._drag_snap_installed = True

    try:
        from libqtile import qtile
        if qtile:
            setup_drag_snap(qtile)
    except Exception:
        pass

    @hook.subscribe.startup
    def init_drag_snap():
        try:
            from libqtile import qtile
            if qtile:
                setup_drag_snap(qtile)
        except Exception:
            pass

    mouse = [
        Drag([], "Button2", lazy.window.set_position_floating(), start=lazy.window.get_position()),
        Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
        Drag([mod], "Button2", lazy.window.set_position_floating(), start=lazy.window.get_position()),
        Drag(["mod1"], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
        Drag(["mod1"], "Button2", lazy.window.set_position_floating(), start=lazy.window.get_position()),
        Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
        Drag(["mod1"], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
        Click([mod], "Button1", lazy.window.bring_to_front()),
        Click([mod], "Button2", lazy.window.bring_to_front()),
    ]

    # ------------------------
    # ---- FLOATING RULES ----
    # ------------------------
    floating_layout = layout.Floating(
        border_width=2,
        border_focus=colors["border_active"],
        border_normal=colors["border_inactive"],
        float_rules=[
            *layout.Floating.default_float_rules,
            Match(wm_class="confirmreset"),
            Match(wm_class="makebranch"),
            Match(wm_class="maketag"),
            Match(wm_class="ssh-askpass"),
            Match(title="branchdialog"),
            Match(title="pinentry"),
            Match(wm_class="pavucontrol"),
            Match(wm_class="blueman-manager"),
            Match(wm_class="swappy"),
            Match(title="Missing Packages Detected"),
            Match(wm_class="Rofi"),
            Match(wm_class="hyprfrost-welcome"),
            Match(title="HyprFrost Welcome Center"),
        ],
    )

    # ---------------------------
    # ---- WAYLAND INPUT RULES --
    # ---------------------------
    try:
        from libqtile.backend.wayland import InputConfig
        wl_input_rules = {
            "*": InputConfig(natural_scroll=False),
        }
    except ImportError:
        wl_input_rules = None

    # -------------------
    # ---- AUTOSTART ----
    # -------------------
    @hook.subscribe.startup_once
    def autostart():
        script = os.path.expanduser("~/.config/qtile/autostart.sh")
        if os.path.isfile(script) and os.access(script, os.X_OK):
            subprocess.Popen(["${pkgs.bash}/bin/bash", script], start_new_session=True)

    # --------------------------
    # ---- GENERAL BEHAVIOR ----
    # --------------------------
    dgroups_key_binder = None
    dgroups_app_rules = []
    follow_mouse_focus = True
    bring_front_click = False
    floats_kept_above = True
    cursor_warp = False
    auto_fullscreen = False
    focus_on_window_activation = "smart"
    reconfigure_screens = True
    auto_minimize = True
    wmname = "Qtile"
  '';

  # ===========================================================================
  # QTILE AUTOSTART (~/.config/qtile/autostart.sh)
  # ===========================================================================
  home.file.".config/qtile/autostart.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # =============================================================================
      # Qtile Autostart Script (NixOS + Cross-Distro Compatible)
      # =============================================================================

      # Ensure only one instance runs
      exec 200>/tmp/qtile-autostart.lock
      flock -n 200 || exit 0

      # 1. Sync D-Bus and systemd user session environment
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE 2>/dev/null || true
      systemctl --user import-environment WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE 2>/dev/null || true
      export _JAVA_AWT_WM_NONREPARENTING=1

      # 2. Display Layout, Anti-Tearing & Compositor (X11)
      if [ -z "$WAYLAND_DISPLAY" ] && [ -n "$DISPLAY" ]; then
          xrandr --output HDMI-0 --mode 1920x1080 --pos 0x0 --primary --output DP-3 --mode 1920x1080 --pos 1920x0 2>/dev/null || true
          nvidia-settings --assign CurrentMetaMode="HDMI-0: 1920x1080 +0+0 {ForceFullCompositionPipeline=On}, DP-3: 1920x1080 +1920+0 {ForceFullCompositionPipeline=On}" 2>/dev/null || true
          if command -v picom >/dev/null 2>&1; then
              pgrep -x picom >/dev/null || picom -b &
          fi
      fi

      # 3. Keyring, Notifications & Network Applet
      pgrep -x gnome-keyring-d >/dev/null || gnome-keyring-daemon --start --components=secrets &
      pgrep -x dunst >/dev/null || dunst &
      pgrep -x nm-applet >/dev/null || nm-applet &

      # 4. Wayland Clipboard History
      if [ -n "$WAYLAND_DISPLAY" ]; then
          pgrep -x cliphist >/dev/null || wl-paste --type text --watch cliphist store &
      fi
    '';
  };

  # ===========================================================================
  # PICOM COMPOSITOR (~/.config/picom/picom.conf)
  # ===========================================================================
  home.file.".config/picom/picom.conf".text = ''
    # =============================================================================
    # Picom Configuration (X11 Compositor for Qtile)
    # Optimized for NVIDIA RTX, High-FPS Gaming, and Tokyo Night Aesthetics
    # =============================================================================

    backend = "glx";
    glx-copy-from-front = false;
    use-damage = true;
    vsync = true;

    # Unredirect fullscreen windows for direct native GPU scanout in games
    unredir-if-possible = true;
    unredir-if-possible-delay = 0;
    unredir-if-possible-exclude = [];

    corner-radius = 10;
    rounded-corners-exclude = [
        "window_type = 'dock'",
        "window_type = 'desktop'",
        "_NET_WM_STATE *= '_NET_WM_STATE_FULLSCREEN'"
    ];

    shadow = true;
    shadow-radius = 16;
    shadow-opacity = 0.50;
    shadow-offset-x = -16;
    shadow-offset-y = -16;
    shadow-color = "#0f111a";

    shadow-exclude = [
        "name = 'Notification'",
        "class_g = 'Conky'",
        "class_g ?= 'Notify-osd'",
        "class_g = 'Cairo-clock'",
        "window_type = 'dock'",
        "_GTK_FRAME_EXTENTS@"
    ];

    fading = true;
    fade-in-step = 0.04;
    fade-out-step = 0.04;
    fade-delta = 5;
    no-fading-openclose = false;
    fade-exclude = [];

    active-opacity = 1.0;
    inactive-opacity = 0.88;
    frame-opacity = 1.0;
    inactive-opacity-override = false;

    focus-exclude = [
        "class_g = 'Cairo-clock'",
        "class_g = 'slop'",
        "class_g = 'Steam'",
        "_NET_WM_STATE *= '_NET_WM_STATE_FULLSCREEN'"
    ];

    opacity-rule = [
        "100:_NET_WM_STATE *= '_NET_WM_STATE_FULLSCREEN'",
        "100:name *?= 'Hogwarts'",
        "100:class_g = 'Steam'",
        "100:class_g = 'steam_app_'",
        "100:class_g = 'Brave-browser' && focused",
        "95:class_g = 'Brave-browser' && !focused",
        "100:class_g = 'firefox' && focused",
        "95:class_g = 'firefox' && !focused",
        "100:class_g = 'kitty' && focused",
        "90:class_g = 'kitty' && !focused",
        "100:class_g = 'Alacritty' && focused",
        "90:class_g = 'Alacritty' && !focused",
        "92:class_g = 'thunar' && focused",
        "85:class_g = 'thunar' && !focused",
        "92:class_g = 'Thunar' && focused",
        "85:class_g = 'Thunar' && !focused",
        "92:class_g = 'Rofi'",
        "90:class_g = 'discord'",
        "90:class_g = 'Discord'",
        "90:class_g = 'Spotify'",
        "92:class_g = 'pavucontrol'",
        "92:class_g = 'org.pulseaudio.pavucontrol'"
    ];

    blur: {
        method = "dual_kawase";
        strength = 6;
        background = true;
        background-frame = false;
        background-fixed = false;
    };

    blur-background-exclude = [
        "window_type = 'dock'",
        "window_type = 'desktop'",
        "class_g = 'kitty'",
        "class_g = 'Kitty'",
        "class_g = 'Alacritty'",
        "class_g = 'alacritty'",
        "_GTK_FRAME_EXTENTS@",
        "class_g = 'slop'",
        "_NET_WM_STATE *= '_NET_WM_STATE_FULLSCREEN'"
    ];

    wintypes:
    {
        tooltip = { fade = true; shadow = true; opacity = 0.95; focus = true; full-shadow = false; };
        dock = { shadow = false; clip-shadow-above = true; opacity = 0.92; };
        dnd = { shadow = false; };
        popup_menu = { opacity = 0.95; };
        dropdown_menu = { opacity = 0.95; };
    };
  '';
}
