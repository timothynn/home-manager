##############################################################################
# home.nix — Home Manager root module
#
# Declares identity, package list, and imports all sub-modules.
# Program configurations live in their dedicated modules under home/ and
# modules/ — do not add inline program settings here.
##############################################################################
{ config, pkgs, lib, inputs ? {}, username ? "tim", ... }:

let
  dotnetSdks = builtins.concatLists [
    (lib.optionals (pkgs ? dotnet-sdk_6) [ pkgs.dotnet-sdk_6 ])
    (lib.optionals (pkgs ? dotnet-sdk_7) [ pkgs.dotnet-sdk_7 ])
    (lib.optionals (pkgs ? dotnet-sdk_8) [ pkgs.dotnet-sdk_8 ])
    (lib.optionals (pkgs ? dotnet-sdk_9) [ pkgs.dotnet-sdk_9 ])
    (lib.optionals (pkgs ? dotnet-sdk_10) [ pkgs.dotnet-sdk_10 ])
  ];
  # One global dotnet binary in profile; full 6/7/8/9/10 remain in devShell.
  globalDotnet =
    if pkgs ? dotnet-sdk_10 then pkgs.dotnet-sdk_10
    else if pkgs ? dotnet-sdk_9 then pkgs.dotnet-sdk_9
    else if pkgs ? dotnet-sdk_8 then pkgs.dotnet-sdk_8
    else if pkgs ? dotnet-sdk_7 then pkgs.dotnet-sdk_7
    else if pkgs ? dotnet-sdk_6 then pkgs.dotnet-sdk_6
    else null;
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

    # Application launcher
    ./modules/programs/wofi.nix

    # Terminal emulator
    ./home/terminal/kitty.nix

    # Shell: Zsh + Starship prompt + CLI tooling
    ./home/shell/zsh.nix
    ./home/shell/nushell.nix
    ./home/shell/starship.nix
    ./home/shell/cli-tools.nix
    ./home/shell/dashboard.nix
    ./home/shell/github-sync.nix

    # Editor
    ./home/editor/neovim.nix
    ./home/editor/helix.nix

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

    # Dev runtimes / SDKs
    nodejs_24
    postgresql_18
    rustup

    # DevOps / network
    openvpn
    openvpn3
    dbeaver-bin
    github-copilot-cli
    net-tools
    bluez

    # Media
    mpv
    vlc
    yt-dlp

    # Hyprland ecosystem extras
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
  ]) ++ (lib.optionals (globalDotnet != null) [ globalDotnet ]);

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
