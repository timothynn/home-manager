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
      wifi.backend = "iwd";
    };

    firewall = {
      enable          = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
  };

  # Wi-Fi stack for Intel Dual Band Wireless-AC 3160 (iwlwifi).
  networking.wireless.iwd = {
    enable = true;
    settings = {
      Settings = {
        AutoConnect = true;
      };
      General = {
        EnableNetworkConfiguration = true;
      };
    };
  };

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
