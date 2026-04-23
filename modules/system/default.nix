##############################################################################
# modules/system/default.nix
#
# Core system behaviour: bootloader, PipeWire audio, Bluetooth, Polkit,
# XDG portals, and a minimal set of system packages every session needs.
##############################################################################
{ pkgs, lib, ... }:

{
  # ---------------------------------------------------------------------------
  # Bootloader
  # ---------------------------------------------------------------------------
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = lib.mkForce false;
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      theme = pkgs.catppuccin-grub.override {
        flavor = "mocha";
      };
    };
  };

  # ---------------------------------------------------------------------------
  # PipeWire audio (replaces PulseAudio)
  # ---------------------------------------------------------------------------
  services.pulseaudio.enable = false;
  security.rtkit.enable      = true;

  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
    jack.enable       = true;
  };

  # ---------------------------------------------------------------------------
  # Bluetooth
  # ---------------------------------------------------------------------------
  hardware.bluetooth.enable      = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable        = true;

  # Intel Dual Band Wireless-AC 3160 firmware path and module defaults.
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [ pkgs.linux-firmware ];

  # Intel iwlwifi reliability tuning for older AC adapters (3160 in particular).
  # 11n_disable=8 disables MIMO power-save which is the most reliable fix for
  # the 3160's "unavailable" / constant-disconnect states; power_save=0 keeps
  # the radio from parking; bt_coex_active=0 avoids BT-WiFi coex bugs on this
  # chipset.
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0 11n_disable=8 bt_coex_active=0
    options iwlmvm power_scheme=1
  '';

  # ---------------------------------------------------------------------------
  # Security / Seat management
  # ---------------------------------------------------------------------------
  security.polkit.enable = true;

  services.gnome.gnome-keyring.enable = true;

  # ---------------------------------------------------------------------------
  # XDG portals — required by Hyprland, Flatpak, etc.
  # ---------------------------------------------------------------------------
  xdg.portal = {
    enable        = true;
    # Keep GTK portal explicitly; Hyprland portal is provided by Hyprland module.
    extraPortals  = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # ---------------------------------------------------------------------------
  # Removable media / external drives (NTFS, exFAT, Nautilus auto-mount)
  # ---------------------------------------------------------------------------
  services.udisks2.enable = true;
  services.gvfs.enable    = true;          # virtual FS for Nautilus / Thunar
  programs.fuse.userAllowOther = true;     # allow users to mount FUSE volumes

  # ---------------------------------------------------------------------------
  # Shell — must be enabled system-wide to be used as login shell
  # ---------------------------------------------------------------------------
  programs.zsh.enable = true;

  # ---------------------------------------------------------------------------
  # Containers — rootless Podman with Docker CLI compatibility
  # ---------------------------------------------------------------------------
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      # Alias `docker` -> `podman` and expose the Docker socket so tools that
      # expect Docker (docker-compose, testcontainers, IDE integrations) work.
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
      autoPrune = {
        enable = true;
        dates  = "weekly";
      };
    };
  };

  # ---------------------------------------------------------------------------
  # System packages (minimal — user packages go in Home Manager)
  # ---------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    # Essentials
    wget curl git pciutils usbutils lshw htop

    # Wayland / compositor utilities
    wl-clipboard grim slurp libnotify
    brightnessctl playerctl pamixer pavucontrol
    networkmanagerapplet

    # GTK runtime (theming)
    glib gtk3 gtk4 gnome-themes-extra adwaita-icon-theme

    # Hardware / power
    acpi lm_sensors
    bluez bluez-tools

    # External drives / Windows NTFS support
    ntfs3g
    exfatprogs

    # Wi-Fi diagnostics (Intel AC 3160 troubleshooting)
    rfkill iw wirelesstools
  ];

  # ---------------------------------------------------------------------------
  # Wayland environment variables (session-wide)
  # ---------------------------------------------------------------------------
  environment.sessionVariables = {
    NIXOS_OZONE_WL              = "1";
    XDG_CURRENT_DESKTOP         = "Hyprland";
    XDG_SESSION_TYPE            = "wayland";
    XDG_SESSION_DESKTOP         = "Hyprland";
    GDK_BACKEND                 = "wayland,x11";
    QT_QPA_PLATFORM             = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    SDL_VIDEODRIVER             = "wayland";
    CLUTTER_BACKEND             = "wayland";
    WLR_NO_HARDWARE_CURSORS     = "1";
    XCURSOR_THEME               = "catppuccin-mocha-dark-cursors";
    XCURSOR_SIZE                = "24";
  };
}
