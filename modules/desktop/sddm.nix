##############################################################################
# modules/desktop/sddm.nix  [NixOS system module]
#
# SDDM display / login manager styled with the Catppuccin Mocha SDDM theme.
# Wayland mode is enabled so the greeter runs natively on Wayland.
##############################################################################
{ pkgs, ... }:

let
  # Build the theme once; reuse in both `theme` path and `systemPackages`.
  catppuccinSddm = pkgs.catppuccin-sddm.override {
    flavor     = "mocha";
    accent     = "mauve";
    font       = "JetBrains Mono";
    fontSize   = "10";
    background = ../../wallpapers/catppuccin-mocha-ridges.jpg;
  };
in
{
  services.displayManager.sddm = {
    enable         = true;
    wayland.enable = true;
    # Full store path avoids theme-name ambiguity (directory is catppuccin-mocha-mauve).
    theme          = "${catppuccinSddm}/share/sddm/themes/catppuccin-mocha-mauve";
    package        = pkgs.kdePackages.sddm;
    settings = {
      Theme = {
        CursorTheme = "catppuccin-mocha-dark-cursors";
        Font        = "JetBrainsMono Nerd Font";
      };
    };
  };

  environment.systemPackages = [
    catppuccinSddm
    pkgs.catppuccin-cursors.mochaDark
  ];
}
