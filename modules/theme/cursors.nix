##############################################################################
# modules/theme/cursors.nix  [Home Manager module]
#
# Catppuccin Mocha cursor theme applied at the Home Manager / GTK level.
# The SDDM cursor is set separately in modules/desktop/sddm.nix.
##############################################################################
{ pkgs, ... }:

{
  home.pointerCursor = {
    name    = "catppuccin-mocha-dark-cursors";
    package = pkgs.catppuccin-cursors.mochaDark;
    size    = 24;

    # Propagate to GTK and X11 as well
    gtk.enable = true;
    x11.enable = true;
  };
}
