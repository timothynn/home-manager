##############################################################################
# modules/theme/qt.nix  [Home Manager module]
#
# Qt5/Qt6 theming via Kvantum so Qt apps match the Catppuccin Mocha GTK look.
##############################################################################
{ pkgs, ... }:

{
  qt = {
    enable = true;

    # Use Kvantum as the Qt5/6 style engine
    platformTheme.name = "kvantum";

    style = {
      name    = "kvantum";
      package = pkgs.catppuccin-kvantum.override {
        accent  = "mauve";
        variant = "mocha";
      };
    };
  };

  # Point Kvantum at the Catppuccin theme via XDG config
  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=catppuccin-mocha-mauve
  '';
}
