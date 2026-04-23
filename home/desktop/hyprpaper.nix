##############################################################################
# home/desktop/hyprpaper.nix
#
# Wallpaper daemon for Hyprland. Previously invoked as `exec-once = hyprpaper`
# out of hyprland.nix, which caused a race: the daemon started before any
# monitor was registered, `wallpaper = ,<path>` silently no-op'd on every
# output, and the screen stayed black. We now route through Home Manager's
# `services.hyprpaper` module which:
#   - installs `hyprpaper`
#   - writes `~/.config/hypr/hyprpaper.conf` from `settings` below
#   - runs hyprpaper under a systemd user unit gated on
#     `graphical-session.target` so it starts *after* Hyprland is up and
#     the monitor is live — which raw exec-once ordering did not guarantee.
#
# The raw `exec-once = hyprpaper` line in hyprland.nix is removed; keep this
# module as the single source of truth for the daemon.
##############################################################################
{ config, ... }:

let
  wallpaper = "${config.home.homeDirectory}/Pictures/wallpapers/catppuccin-mocha-ridges.jpg";
in
{
  # Deploy the wallpaper into the user's home directory. Keeping it at a
  # stable ~/Pictures path (rather than referencing the Nix store) means
  # hyprlock + SDDM + hyprpaper can all point at the same string.
  home.file."Pictures/wallpapers/catppuccin-mocha-ridges.jpg".source =
    ../../wallpapers/catppuccin-mocha-ridges.jpg;

  services.hyprpaper = {
    enable = true;
    settings = {
      # ipc=on enables `hyprctl hyprpaper ...` for runtime switching.
      ipc     = "on";
      splash  = false;

      # Must preload every path referenced below (or by later
      # `hyprctl hyprpaper wallpaper` calls).
      preload = [ wallpaper ];

      # Apply to ALL monitors. Written as a list-of-attrs per the
      # services.hyprpaper schema; serialises to `wallpaper = ,<path>`.
      wallpaper = [
        { monitor = ""; path = wallpaper; }
      ];
    };
  };
}
