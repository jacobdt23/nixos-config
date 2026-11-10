{ ... }:

{
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
}
