##############################################################################
# modules/desktop/hyprlock.nix  [Home Manager module]
#
# Hyprlock — GPU-accelerated Wayland lock screen for Hyprland.
# Displays a blurred screenshot with a centred clock and password field.
# Catppuccin Mocha colour palette throughout.
# Imported from home.nix, NOT from configuration.nix.
##############################################################################
{ config, pkgs, ... }:

let
  wallpaper = "${config.home.homeDirectory}/Pictures/wallpapers/voxel-city.jpg";
in

{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor         = true;
        grace               = 5;
        no_fade_in          = false;
      };

      background = [
        {
          path         = wallpaper;
          blur_passes  = 3;
          blur_size    = 6;
          noise        = 0.0117;
          contrast     = 0.93;
          brightness   = 0.80;
          vibrancy     = 0.1696;
          vibrancy_darkness = 0.0;
        }
      ];

      input-field = [
        {
          size             = "320, 62";
          position         = "0, -120";
          monitor          = "";
          dots_center      = true;
          fade_on_empty    = false;
          font_color       = "rgb(cdd6f4)";
          inner_color      = "rgb(1e1e2e)";
          outer_color      = "rgb(cba6f7)";
          check_color      = "rgb(a6e3a1)";
          fail_color       = "rgb(f38ba8)";
          outline_thickness = 2;
          placeholder_text = "<i>Password</i>";
          shadow_passes    = 3;
        }
      ];

      label = [
        # Large clock
        {
          monitor     = "";
          text        = "cmd[update:1000] echo \"$(date +'%H:%M')\"";
          color       = "rgba(cdd6f4ff)";
          font_size   = 90;
          font_family = "JetBrainsMono Nerd Font Bold";
          position    = "0, 250";
          halign      = "center";
          valign      = "center";
        }
        # Date
        {
          monitor     = "";
          text        = "cmd[update:60000] echo \"$(date +'%A, %d %B %Y')\"";
          color       = "rgba(a6adc8ff)";
          font_size   = 22;
          font_family = "JetBrainsMono Nerd Font";
          position    = "0, 150";
          halign      = "center";
          valign      = "center";
        }
      ];
    };
  };

  # hypridle — idle daemon that triggers hyprlock
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd  = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd         = "pidof hyprlock || hyprlock";
      };
      listener = [
        {
          timeout    = 300;
          on-timeout = "hyprlock";
        }
        {
          timeout    = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume  = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
