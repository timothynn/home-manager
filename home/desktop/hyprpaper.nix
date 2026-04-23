{ config, ... }:

let
  wallpaper = "${config.home.homeDirectory}/Pictures/wallpapers/catppuccin-mocha-ridges.jpg";
in
{
  # Deploy the wallpaper from the flake source into the user's home directory.
  home.file."Pictures/wallpapers/catppuccin-mocha-ridges.jpg".source =
    ../../wallpapers/catppuccin-mocha-ridges.jpg;

  # ~/.config/hypr/hyprpaper.conf
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ${wallpaper}
    wallpaper = ,${wallpaper}
    splash = false
    ipc = on
  '';
}
