##############################################################################
# home.nix — Home Manager root module
#
# Declares identity, package list, and imports all sub-modules.
# Program configurations live in their dedicated modules under home/ and
# modules/ — do not add inline program settings here.
##############################################################################
{ config, pkgs, lib, inputs ? {}, username ? "tim", ... }:

# NOTE: .NET is disabled. Uncomment the let-binding below and the
# `++ (lib.optional …)` on home.packages to re-enable SDKs 6/8/10.
# See also flake.nix (permittedInsecurePackages + dotnet devShell) and
# hosts/default/configuration.nix (permittedInsecurePackages).
#
# let
#   # Multi-SDK .NET via the nixpkgs-blessed combinator: 6, 8, 10 side-by-side
#   # on the same `dotnet` binary so `global.json` / `TargetFramework` routing
#   # works without a devShell. Each SDK is lib.optional-guarded so eval does
#   # not fail on channels that have not yet packaged one of them (.NET 10
#   # especially is recent on nixos-unstable).
#   dotnetCorePackages = pkgs.dotnetCorePackages;
#   dotnetSdkList =
#        (lib.optional (dotnetCorePackages ? sdk_6_0)  dotnetCorePackages.sdk_6_0)
#     ++ (lib.optional (dotnetCorePackages ? sdk_8_0)  dotnetCorePackages.sdk_8_0)
#     ++ (lib.optional (dotnetCorePackages ? sdk_10_0) dotnetCorePackages.sdk_10_0);
#   dotnetCombined =
#     if dotnetSdkList == [] then null
#     else dotnetCorePackages.combinePackages dotnetSdkList;
# in

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
    hyprpaper   # wallpaper daemon invoked by `exec-once = hyprpaper`
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
  ]);
  # ]) ++ (lib.optional (dotnetCombined != null) dotnetCombined);   # re-enable with the let-binding above

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
