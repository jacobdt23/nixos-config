{ ... }:

{
  # ===========================================================================
  # KITTY (Dracula Terminal)
  # ===========================================================================
  home.file.".config/kitty/kitty.conf".text = ''
    # Dracula Kitty Configuration
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

    background_opacity 1.0
    dynamic_background_opacity no

    # Dracula Color Palette
    foreground            #f8f8f2
    background            #282a36
    selection_foreground  #ffffff
    selection_background  #44475a

    cursor                #f8f8f2
    cursor_text_color     #282a36

    url_color             #8be9fd

    active_border_color   #bd93f9
    inactive_border_color #6272a4

    active_tab_foreground   #282a36
    active_tab_background   #f8f8f2
    inactive_tab_foreground #282a36
    inactive_tab_background #6272a4

    # Black
    color0  #21222c
    color8  #6272a4

    # Red
    color1  #ff5555
    color9  #ff6e6e

    # Green
    color2  #50fa7b
    color10 #69ff94

    # Yellow
    color3  #f1fa8c
    color11 #ffffa5

    # Blue
    color4  #bd93f9
    color12 #d6acff

    # Magenta
    color5  #ff79c6
    color13 #ff92df

    # Cyan
    color6  #8be9fd
    color14 #a4ffff

    # White
    color7  #f8f8f2
    color15 #ffffff
  '';
}
