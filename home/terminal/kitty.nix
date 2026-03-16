##############################################################################
# home/terminal/kitty.nix  [Home Manager module]
#
# Kitty terminal emulator — JetBrains Mono, Catppuccin Mocha, ligatures,
# transparent background to play nicely with Hyprland blur.
##############################################################################
{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };

    settings = {
      # ── Rendering ─────────────────────────────────────────────────────
      enable_audio_bell        = false;
      confirm_os_window_close  = 0;
      scrollback_lines         = 12000;

      # Transparency (matches Hyprland blur backdrop)
      background_opacity       = "0.92";
      dynamic_background_opacity = true;

      # Ligatures — requires a Nerd Font with ligature support
      font_features            = "JetBrainsMono-Regular +calt +clig +liga";

      # ── Cursor ────────────────────────────────────────────────────────
      cursor_shape             = "beam";
      cursor_beam_thickness    = "1.8";
      cursor_blink_interval    = "0.5";

      # ── Window aesthetics ─────────────────────────────────────────────
      window_padding_width     = 5;
      window_padding_height    = 5;

      # ── Tab bar ───────────────────────────────────────────────────────
      tab_bar_style            = "powerline";
      tab_powerline_style      = "slanted";
      active_tab_font_style    = "bold";
      inactive_tab_font_style  = "normal";

      # ── URL handling ──────────────────────────────────────────────────
      open_url_with            = "xdg-open";
      detect_urls              = true;

      # ── Shell integration ─────────────────────────────────────────────
      shell_integration        = "enabled";

      # ── Performance ───────────────────────────────────────────────────
      repaint_delay            = 10;
      sync_to_monitor          = true;
    };

    keybindings = {
      # Windows
      "ctrl+shift+enter" = "new_window";
      "ctrl+shift+w"     = "close_window";
      "ctrl+shift+right" = "next_window";
      "ctrl+shift+left"  = "previous_window";

      # Splits
      "ctrl+shift+d"     = "launch --location=vsplit";
      "ctrl+shift+minus" = "launch --location=hsplit";
      "ctrl+shift+h"     = "neighboring_window left";
      "ctrl+shift+l"     = "neighboring_window right";
      "ctrl+shift+k"     = "neighboring_window top";
      "ctrl+shift+j"     = "neighboring_window bottom";

      # Tabs
      "ctrl+shift+t"     = "new_tab";
      "ctrl+tab"         = "next_tab";
      "ctrl+shift+tab"   = "previous_tab";

      # Font size
      "ctrl+equal"       = "change_font_size all +1.0";
      "ctrl+minus"       = "change_font_size all -1.0";
      "ctrl+0"           = "change_font_size all 0";

      # Clipboard
      "ctrl+shift+c"     = "copy_to_clipboard";
      "ctrl+shift+v"     = "paste_from_clipboard";
    };
  };
}
