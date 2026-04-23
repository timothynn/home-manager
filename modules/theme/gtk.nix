##############################################################################
# modules/theme/gtk.nix  [Home Manager module]
#
# GTK 2/3/4 theme: Catppuccin Mocha + Mauve accent, dark mode forced.
# Papirus-Dark icon theme.
# JetBrains Mono as the default GTK font.
##############################################################################
{ pkgs, config, ... }:

let
  gtkThemeName    = "catppuccin-mocha-mauve-standard+default";
  gtkThemePackage = pkgs.catppuccin-gtk.override {
    accents = [ "mauve" ];
    variant = "mocha";
    size    = "standard";
    # No `tweaks` — the resulting theme dir name matches
    # `catppuccin-mocha-mauve-standard+default` which is what the rest
    # of this module references. Adding a tweak (`black`, `rimless`,
    # `macos`, `float`) would change the directory suffix and break
    # the xdg.configFile paths below.
  };
in
{
  gtk = {
    enable = true;

    theme = {
      name    = gtkThemeName;
      package = gtkThemePackage;
    };

    iconTheme = {
      name    = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };

    # GTK2: point HM at the XDG-compliant path instead of the default
    # ~/.gtkrc-2.0, so everything theme-related lives under ~/.config.
    # No extraConfig — the dark variant of catppuccin-gtk ships its
    # own GTK2 gtkrc and HM already wires it via gtk-theme-name, and
    # `gtk-application-prefer-dark-theme` is GTK3+ only (GTK2 ignores
    # it silently, so it's noise to set here).
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # GSettings (GNOME apps, including anything that honours
  # gtk-application-prefer-dark-theme is a lie — libadwaita apps ignore
  # the theme setting entirely and ONLY read color-scheme here plus the
  # CSS overrides below).
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme    = gtkThemeName;
      icon-theme   = "Papirus-Dark";
      font-name    = "JetBrainsMono Nerd Font 11";
    };
  };

  # libadwaita workaround — GTK4 GNOME apps (Nautilus, Files, Calendar,
  # Settings, etc.) use their own hard-coded Adwaita theme and refuse to
  # honour `gtk.theme.name` above. The only supported override is
  # `~/.config/gtk-4.0/gtk.css` + `gtk-dark.css` + `assets/`, which
  # libadwaita reads on top of its baseline. Symlinking these out of
  # catppuccin-gtk's package gives libadwaita apps the same colours as
  # every other GTK4 app without patching libadwaita itself.
  #
  # If a future libadwaita release changes this override path, set
  # `xdg.configFile."gtk-4.0/..." = lib.mkForce null;` to opt out.
  xdg.configFile = {
    "gtk-4.0/gtk.css".source =
      "${gtkThemePackage}/share/themes/${gtkThemeName}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source =
      "${gtkThemePackage}/share/themes/${gtkThemeName}/gtk-4.0/gtk-dark.css";
    "gtk-4.0/assets".source =
      "${gtkThemePackage}/share/themes/${gtkThemeName}/gtk-4.0/assets";
  };
}
