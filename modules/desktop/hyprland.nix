##############################################################################
# modules/desktop/hyprland.nix  [NixOS system module]
#
# System-level Hyprland enablement.
# The per-user config (keybinds, animations, rules) lives in
# home/desktop/hyprland.nix (Home Manager wayland.windowManager.hyprland).
##############################################################################
{ pkgs, inputs, ... }:

{
  programs.hyprland = {
    enable          = true;
    # Pin to the hyprland flake input for latest features
    package         = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };
}
