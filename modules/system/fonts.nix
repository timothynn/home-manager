##############################################################################
# modules/system/fonts.nix
#
# Installs all required fonts and configures fontconfig defaults.
# JetBrains Mono Nerd Font is used for terminals, editors, and Waybar.
##############################################################################
{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      # Primary coding / UI font
      nerd-fonts.jetbrains-mono

      # Secondary nerd fonts for icons everywhere
      nerd-fonts.fira-code
      nerd-fonts.symbols-only
      nerd-fonts.noto

      # Broad language / emoji coverage
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      dejavu_fonts
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono" ];
        sansSerif  = [ "JetBrainsMono Nerd Font" "Noto Sans" "Liberation Sans" ];
        serif      = [ "JetBrainsMono Nerd Font" "Noto Serif" "Liberation Serif" ];
        emoji      = [ "Noto Color Emoji" ];
      };

      # Subpixel rendering
      subpixel.rgba = "rgb";
      hinting = {
        enable = true;
        style  = "slight";
      };
      antialias = true;
    };
  };
}
