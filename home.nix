##############################################################################
# home.nix — Home Manager root module
#
# Declares identity, package list, and imports all sub-modules.
# Program configurations live in their dedicated modules under home/ and
# modules/ — do not add inline program settings here.
##############################################################################
{ config, pkgs, lib, inputs ? {}, username ? "tim", ... }:

# .NET 6 only for now. SDKs 8 and 10 are left commented for later — see
# the commented entries below and the matching ones in flake.nix and
# hosts/default/configuration.nix.
#
# Current nixpkgs no longer exposes the top-level `sdk_6_0` alias; the
# latest 6.0 LTS patch band is `sdk_6_0_4xx` (v6.0.428). The lib.optional
# guard still keeps eval safe if a future channel rename drops the attr.
let
  dotnetCorePackages = pkgs.dotnetCorePackages;
  dotnetSdkList =
       (lib.optional (dotnetCorePackages ? sdk_6_0_4xx) dotnetCorePackages.sdk_6_0_4xx)
    # ++ (lib.optional (dotnetCorePackages ? sdk_8_0)     dotnetCorePackages.sdk_8_0)
    # ++ (lib.optional (dotnetCorePackages ? sdk_10_0)    dotnetCorePackages.sdk_10_0)
  ;
  dotnetCombined =
    if dotnetSdkList == [] then null
    else dotnetCorePackages.combinePackages dotnetSdkList;
in

{
  # ── Identity ───────────────────────────────────────────────────────────────
  home.username    = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion  = "26.05";

  # ── Module imports ──────────────────────────────────────────────────────────
  imports = [
    # Global theme defaults (must come first)
    ./home/theme/catppuccin.nix

    # Desktop: Hyprland window manager + Waybar
    ./home/desktop/hyprland.nix
    ./home/desktop/hyprpaper.nix
    ./home/desktop/waybar.nix

    # Desktop services: notifications + lock screen
    ./modules/desktop/mako.nix
    ./modules/desktop/hyprlock.nix

    # Terminal emulator
    ./home/terminal/kitty.nix

    # Shell: Zsh + Starship prompt + CLI tooling
    ./home/shell/zsh.nix
    ./home/shell/nushell.nix
    ./home/shell/starship.nix
    ./home/shell/cli-tools.nix
    ./home/shell/dashboard.nix
    ./home/shell/github-sync.nix
    ./home/shell/node.nix

    # Editor
    ./home/editor/neovim.nix
    ./home/editor/helix.nix
    ./home/editor/vscode.nix

    # Developer tools
    ./modules/programs/git.nix
    ./modules/programs/firefox.nix
    ./modules/programs/rofi.nix

    # Visual theming: GTK, Qt, cursors
    ./modules/theme/gtk.nix
    ./modules/theme/qt.nix
    ./modules/theme/cursors.nix
  ];

  # ── User packages ───────────────────────────────────────────────────────────
  # Packages without dedicated Home Manager module options.
  # CLI tools with HM options are configured in home/shell/cli-tools.nix.
  home.packages = (with pkgs; [
    # Productivity / apps
    firefox
    spotify
    emacs
    nautilus
    direnv
    postman
    vscode
    code-cursor
    cursor-cli
    gh
    ollama
    discord
    opencode

    # Dev runtimes / SDKs (nodejs is installed via home/shell/node.nix
    # alongside a user-writable npm global prefix).
    # Pinned to v16 for compatibility with the projects currently
    # targeting that major; bump deliberately when you upgrade schemas.
    postgresql_16
    rustup

    # DevOps / network
    # Note: openvpn3 is installed system-wide by
    # modules/services/seabury-vpn.nix (via `programs.openvpn3.enable`) so
    # its D-Bus/systemd services are wired up. Classic openvpn (v2) stays
    # here as a user binary for ad-hoc `.ovpn` profiles.
    openvpn
    dbeaver-bin
    beekeeper-studio
    github-copilot-cli
    net-tools
    bluez

    # Media
    mpv
    vlc
    yt-dlp

    # Hyprland ecosystem extras
    # hyprpaper is managed by services.hyprpaper (see home/desktop/hyprpaper.nix)
    # which installs the package and runs it as a systemd user service.
    hyprsunset
    hyprshot
    hyprspace
    hyprpicker
    hyprnotify
    hyprcursor
    hyprshutdown
    hyprlauncher
    hyprland-workspaces

    # Misc utilities
    tree
    lolcat
    cowsay
    hello
    wl-clipboard
  ]) ++ (lib.optional (dotnetCombined != null) dotnetCombined);

  # ── Session variables ───────────────────────────────────────────────────────
  home.sessionVariables = {
    EDITOR  = "nvim";
    VISUAL  = "nvim";
    BROWSER = "firefox";
    TERM    = "xterm-256color";
  };

  # ── XDG directories ─────────────────────────────────────────────────────────
  xdg = {
    enable = true;
    userDirs = {
      enable        = true;
      createDirectories = true;
      download      = "${config.home.homeDirectory}/Downloads";
      documents     = "${config.home.homeDirectory}/Documents";
      pictures      = "${config.home.homeDirectory}/Pictures";
      videos        = "${config.home.homeDirectory}/Videos";
      music         = "${config.home.homeDirectory}/Music";
      desktop       = "${config.home.homeDirectory}/Desktop";
      templates     = "${config.home.homeDirectory}/Templates";
      publicShare   = "${config.home.homeDirectory}/Public";
      extraConfig   = {
        SCREENSHOTS = "${config.home.homeDirectory}/Pictures/screenshots";
      };
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html"                = "firefox.desktop";
        "x-scheme-handler/http"   = "firefox.desktop";
        "x-scheme-handler/https"  = "firefox.desktop";
        "image/png"               = "org.gnome.eog.desktop";
        "image/jpeg"              = "org.gnome.eog.desktop";
        "video/mp4"               = "mpv.desktop";
        "video/mkv"               = "mpv.desktop";
        "inode/directory"         = "org.gnome.Nautilus.desktop";
      };
    };
  };

  home.activation.createScreenshotDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${config.home.homeDirectory}/Pictures/screenshots"
  '';

  programs.home-manager.enable = true;
  programs.mullvad-vpn.enable  = true;
}
