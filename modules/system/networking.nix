##############################################################################
# modules/system/networking.nix
#
# Hostname, NetworkManager, firewall, and SSH daemon.
##############################################################################
{ lib, ... }:

{
  networking = {
    hostName = lib.mkDefault "nixos";

    networkmanager = {
      enable = true;
      # Use NM's default wifi backend (wpa_supplicant). iwd was tried for
      # the AC 3160 but left the radio stuck "unavailable" in `nmcli d`
      # (wlan0 present, no scans, wifi-p2p endpoint unavailable). Revert
      # to wpa_supplicant — historical NM default, widest coverage, best
      # debugged path on NixOS. iwd can be revisited after the laptop is
      # stable on wpa_supplicant.
    };

    firewall = {
      enable          = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
  };

  # Wi-Fi stack for Intel Dual Band Wireless-AC 3160 (iwlwifi) is owned by
  # NetworkManager + wpa_supplicant (NM default). `networking.wireless.*`
  # (wpa_supplicant *standalone*) and `networking.wireless.iwd` are both
  # deliberately disabled: NM will manage wpa_supplicant itself. Firmware,
  # kernel module, and iwlwifi tuning live in modules/system/default.nix.

  services.resolved = {
    enable = true;
    settings.Resolve.DNSSEC = "allow-downgrade";
  };

  networking.nameservers = [ "1.1.1.1" "1.0.0.1" "9.9.9.9" ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin        = "no";
    };
  };
}
