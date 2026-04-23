##############################################################################
# home/editor/vscode.nix — VSCode / Cursor keyring wiring
#
# Runtime symptom: the "Sign in to sync your settings" / "Sign in with GitHub"
# flow in VSCode fails with a keyring-encryption dialog even though the
# session has a working D-Bus Secret Service. Diagnosis from the target box:
#
#   $ dbus-send --session --dest=org.freedesktop.secrets --print-reply \
#       /org/freedesktop/secrets org.freedesktop.DBus.Introspectable.Introspect
#   method return … (success — Secret Service IS exposed)
#
# i.e. gnome-keyring-daemon (started via PAM) is answering on the session
# bus, but VSCode's Electron still falls back to the "basic" plaintext
# store. This is a long-standing Electron-on-non-GNOME bug: Electron's
# auto-detection of the password backend probes GNOME_KEYRING_CONTROL /
# XDG_CURRENT_DESKTOP and gets confused on Hyprland/sway, so it decides
# "no keyring" and pops the "weaker encryption" dialog despite libsecret
# being perfectly reachable over D-Bus.
#
# Upstream-blessed workaround is to pin the backend explicitly via the
# `argv.json` config file that VSCode reads before the window opens.
# `gnome-libsecret` speaks to whatever Secret Service is on the bus —
# gnome-keyring here — so the name is slightly misleading: it is not
# GNOME-specific, it just forces the libsecret code path.
#
# Same file shape works for code-cursor (Electron fork of VSCode) at
# `~/.config/Cursor/argv.json`.
##############################################################################
{ ... }:

let
  argv = {
    # Force VSCode's keyring backend. Without this, Electron's auto-probe
    # falls back to `basic` (obfuscated plaintext under ~/.config/Code)
    # whenever it can't positively identify a GNOME/KDE session, which is
    # every Hyprland session.
    password-store = "gnome-libsecret";

    # Wayland-native rendering on Hyprland. VSCode defaults to XWayland
    # otherwise, which works but means blurry fractional scaling and
    # extra input-method hops. `auto` lets Electron still fall back to
    # X11 on sessions without a Wayland socket (VNC, TTY, etc).
    "enable-features" = "UseOzonePlatform,WaylandWindowDecorations";
    "ozone-platform-hint" = "auto";
  };
  argvJson = builtins.toJSON argv;
in
{
  # Managed argv.json for both editors. VSCode reads this at startup and
  # passes the flags to its own Electron before any window opens. Using
  # xdg.configFile so it lands in $XDG_CONFIG_HOME (~/.config by default)
  # and is cleaned up by `home-manager switch` on removal.
  # The `vscode` / `code-cursor` binaries themselves are installed as
  # top-level entries in home.packages (see home.nix); nothing to wire
  # up here beyond the argv.json.
  xdg.configFile = {
    "Code/argv.json".text = argvJson;
    "Cursor/argv.json".text = argvJson;
  };
}
