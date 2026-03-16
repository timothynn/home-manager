{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11.0;
    };

    # themeFile = "${pkgs.kitty-themes}/themes/Catppuccin-Mocha.conf";


    settings = {
      # Performance & UX
      enable_audio_bell = false;
      confirm_os_window_close = 0;
      scrollback_lines = 10000;

      # Transparency (plays nice with Hyprland)
      background_opacity = "0.92";
      dynamic_background_opacity = true;

      # Cursor
      cursor_shape = "beam";
      cursor_beam_thickness = 1.5;

      # Padding (important for aesthetics)
      window_padding_width = 5;
      window_padding_height = 5;

      # Tab bar
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      active_tab_font_style = "bold";

      # URL handling
      open_url_with = "xdg-open";

      # Shell integration
      shell_integration = "enabled";
    };

    keybindings = {
      "ctrl+shift+enter" = "new_window";
      "ctrl+shift+w" = "close_window";
      "ctrl+shift+right" = "next_window";
      "ctrl+shift+left" = "previous_window";
    };
  };
}

