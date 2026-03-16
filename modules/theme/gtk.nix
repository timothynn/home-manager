##############################################################################
# modules/theme/gtk.nix  [Home Manager module]
#
# GTK 2/3/4 theme: Catppuccin Mocha + Mauve accent.
# Papirus-Dark icon theme with Catppuccin folder colours.
# JetBrains Mono as the default GTK font.
##############################################################################
{ pkgs, ... }:

{
  gtk = {
    enable = true;

    theme = {
      name    = "catppuccin-mocha-mauve-standard+default";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        variant = "mocha";
      };
    };

    iconTheme = {
      name    = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # Ensure GTK4 theming propagates through dconf
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme    = "catppuccin-mocha-mauve-standard+default";
      icon-theme   = "Papirus-Dark";
      font-name    = "JetBrainsMono Nerd Font 11";
    };
  };
}
