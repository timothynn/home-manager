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

  # Intel Dual Band Wireless-AC 3160 firmware.
  # enableAllFirmware pulls in the full redistributable firmware set
  # (strictly a superset of enableRedistributableFirmware) — some 3160
  # revisions ship blobs that only land in the broader package.
  # `pkgs.linux-firmware` is already what the options install; re-listing
  # it under `hardware.firmware` is redundant and has been dropped.
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware             = true;

  # Intel iwlwifi tuning for the AC 3160. Runtime dmesg on this box shows:
  #
  #   iwlwifi 0000:55:00.0: FW error in SYNC CMD UNKNOWN
  #   iwlwifi 0000:55:00.0: Failed to send DQA enabling command: -5
  #   iwlwifi 0000:55:00.0: Device is not enabled - cannot dump error
  #
  # Root cause: the AC 3160's latest public firmware is
  # `iwlwifi-3160-ucode-17` and modern iwlwifi sends a "Dynamic Queue
  # Allocation" enable command firmware 17 doesn't fully implement. The
  # firmware rejects the command with -EIO, the driver bails, and the
  # radio sticks at "unavailable" / "Could not set interface UP".
  #
  # The documented workaround is to force the driver onto the pre-DQA
  # code path by disabling 802.11n (`11n_disable=1`) and moving crypto
  # into software (`swcrypto=1`). Combined with the two existing AC 3160
  # fixes (power_save=0 to stop the radio parking, bt_coex_active=0 to
  # avoid BT/WiFi coex hangs on this antenna-sharing chipset), this gets
  # the 3160 back to 2.4/5 GHz 11g/11a association at reduced throughput
  # — the trade-off for no 11n is ~54 Mbit/s max instead of ~150 Mbit/s,
  # which is almost always fine over a home link.
  #
  # If this combo does not fix the DQA error, the next knob is
  # `boot.kernelPackages = pkgs.linuxPackages_lts` below — an older
  # kernel whose iwlwifi doesn't assume DQA firmware support.
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0 bt_coex_active=0 11n_disable=1 swcrypto=1
  '';

  # Run a recent kernel — every LTS bump carries iwlwifi / iwlmvm fixes that
  # materially help the AC 3160. Swap to linuxPackages_lts if you ever hit a
  # regression, but the default should be "latest".
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Intel CPU microcode updates (security + silicon errata).
  hardware.cpu.intel.updateMicrocode = true;

  # ---------------------------------------------------------------------------
  # Firmware updates (BIOS, dock, Thunderbolt, WiFi/BT module) via fwupd.
  # Manual refresh: `fwupdmgr refresh && fwupdmgr update`.
  # ---------------------------------------------------------------------------
  services.fwupd.enable = true;

  # ---------------------------------------------------------------------------
  # SSD TRIM (weekly timer; safe on every modern SSD / NVMe).
  # ---------------------------------------------------------------------------
  services.fstrim.enable = true;

  # ---------------------------------------------------------------------------
  # zram compressed swap — effectively doubles usable RAM on laptops with
  # 8-16 GB without touching disk. Uses zstd at 50% of physical memory.
  # ---------------------------------------------------------------------------
  zramSwap = {
    enable        = true;
    algorithm     = "zstd";
    memoryPercent = 50;
  };

  # ---------------------------------------------------------------------------
  # earlyoom — prevents hard lockups when memory pressure spikes. Fires
  # before the kernel OOM killer can stall the whole system under swap thrash.
  # ---------------------------------------------------------------------------
  services.earlyoom = {
    enable            = true;
    freeMemThreshold  = 5;   # kill when < 5% RAM free
    freeSwapThreshold = 10;  # and < 10% swap free
  };

  # ---------------------------------------------------------------------------
  # Security / Seat management
  # ---------------------------------------------------------------------------
  security.polkit.enable = true;

  # Hyprlock has no PAM entry on NixOS by default — without this, hyprlock
  # cannot consult PAM and every unlock attempt fails silently. The empty
  # attr-set accepts the defaults (pam_unix + optional gnome_keyring on
  # success), which is what we want for a lock screen.
  security.pam.services.hyprlock = {};

  services.gnome.gnome-keyring.enable = true;
  # Unlock gnome-keyring automatically at graphical login via SDDM/PAM.
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring  = true;

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

    # Wi-Fi diagnostics (Intel AC 3160 troubleshooting).
    # Note: `rfkill` is no longer a standalone package in nixpkgs — it's
    # provided by `util-linux`, which is already pulled in by the base
    # system. `wirelesstools` ships `iwconfig` / `iwlist`; `iw` is the
    # modern nl80211 CLI.
    iw wirelesstools
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
    # WLR_NO_HARDWARE_CURSORS is an NVIDIA-only workaround; on Intel graphics
    # it forces software cursors which causes flicker and extra latency. Do
    # not re-add unless `hardware.nvidia` is enabled.
    XCURSOR_THEME               = "catppuccin-mocha-dark-cursors";
    XCURSOR_SIZE                = "24";
  };
}
