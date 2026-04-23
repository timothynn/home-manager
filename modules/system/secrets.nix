##############################################################################
# modules/system/secrets.nix
#
# sops-nix wiring. Two independent buckets are defined, each guarded by
# `builtins.pathExists` so this module stays eval-safe on a fresh machine
# that hasn't populated the encrypted blobs yet:
#
#   1. Seabury VPN profile — three pfSense-generated files (client.conf,
#      CA cert, tls-crypt key) encrypted as sops binary blobs under
#      secrets/vpn-*.  Decrypted at activation time into
#      /etc/openvpn/client/keys/, where `programs.openvpn3` + the
#      docs/seabury-vpn.md runbook expect them.  The `ca ...` and
#      `tls-crypt ...` directives inside the encrypted `client.conf`
#      reference the other two files by their original pfSense names,
#      so the materialised `path =` values below MUST match those names.
#
#   2. (optional, legacy) secrets.yaml — YAML-structured sops secrets.
#      Currently just defines a placeholder `githubToken` key that the
#      rest of the flake does not consume yet.  Left in place so a
#      future `secrets/secrets.yaml` commit lights up without another
#      module edit.
#
# Age key bootstrap on a new machine:
#   mkdir -p ~/.config/sops/age
#   age-keygen -o ~/.config/sops/age/keys.txt
#   awk '/^# public key:/ {print $NF}' ~/.config/sops/age/keys.txt
#   # add that pubkey to `.sops.yaml`, then re-encrypt any blobs that
#   # need to be readable by this machine.
##############################################################################
{ lib, pkgs, ... }:

let
  hasSopsFile   = builtins.pathExists ../../secrets/secrets.yaml;
  hasVpnSecrets =
       builtins.pathExists ../../secrets/vpn-client.conf
    && builtins.pathExists ../../secrets/vpn-ca.crt
    && builtins.pathExists ../../secrets/vpn-tls.key;
in
{
  environment.systemPackages = with pkgs; [ sops age ssh-to-age ];

  sops = lib.mkMerge [
    # Common wiring (age keyfile) — needed as soon as EITHER bucket is
    # populated. The private half of this keypair lives only on disk at
    # ~/.config/sops/age/keys.txt; restore it from your password
    # manager when reinstalling.
    (lib.mkIf (hasSopsFile || hasVpnSecrets) {
      age = {
        keyFile     = "/home/tim/.config/sops/age/keys.txt";
        generateKey = false;
      };
    })

    # Legacy bucket — secrets.yaml (structured, multi-key).
    (lib.mkIf hasSopsFile {
      defaultSopsFile = ../../secrets/secrets.yaml;
      secrets.githubToken = {
        owner = "tim";
        mode  = "0400";
      };
    })

    # VPN bucket — three binary blobs materialised at activation time.
    # The materialised paths match the relative `ca` / `tls-crypt`
    # references inside the encrypted client.conf, so the config
    # resolves them without any path rewriting.
    (lib.mkIf hasVpnSecrets {
      secrets = {
        "vpn/client.conf" = {
          format   = "binary";
          sopsFile = ../../secrets/vpn-client.conf;
          path     = "/etc/openvpn/client/keys/client.conf";
          owner    = "root";
          group    = "root";
          mode     = "0600";
        };
        "vpn/ca.crt" = {
          format   = "binary";
          sopsFile = ../../secrets/vpn-ca.crt;
          path     = "/etc/openvpn/client/keys/pfSense-UDP4-1194-ca.crt";
          owner    = "root";
          group    = "root";
          mode     = "0600";
        };
        "vpn/tls.key" = {
          format   = "binary";
          sopsFile = ../../secrets/vpn-tls.key;
          path     = "/etc/openvpn/client/keys/pfSense-UDP4-1194-tls.key";
          owner    = "root";
          group    = "root";
          mode     = "0600";
        };
      };
    })
  ];

  # Keys directory pre-created 0700 root:root so sops-nix drops the
  # three files into a properly-locked-down parent on every activation.
  systemd.tmpfiles.rules = lib.mkIf hasVpnSecrets [
    "d /etc/openvpn/client/keys 0700 root root -"
  ];
}
