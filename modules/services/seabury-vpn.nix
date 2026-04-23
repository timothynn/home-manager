##############################################################################
# modules/services/seabury-vpn.nix
#
# Seabury OpenVPN client — installs the CLI tooling and auto-starts the
# VPN on boot, matching the official Seabury gitlab runbook:
#
#   openvpn3 session-start --config /etc/openvpn/client/keys/client.conf
#   (auth with gitlab.seaburymro.com credentials; set tun-mtu 1380)
#
# NOTE: This module does *not* ship `client.conf` or credentials — both are
# sensitive and must be placed out-of-band by the admin (see RUNBOOK block
# at the bottom of this file). The systemd unit is guarded by
# ConditionPathExists so it silently no-ops until the file is in place.
##############################################################################
{ pkgs, ... }:

let
  vpnDir    = "/etc/openvpn/client/keys";
  vpnConf   = "${vpnDir}/client.conf";
in
{
  # CLI tooling. Ship both stacks so the Seabury gitlab runbook commands
  # (`openvpn3 session-start` / `session-manage`) work verbatim, while the
  # auto-start unit below uses the classic OpenVPN daemon for a simpler
  # systemd integration (no user D-Bus dependency on a system service).
  environment.systemPackages = with pkgs; [
    openvpn        # classic openvpn2 — daemonises cleanly under systemd
    openvpn3       # matches Seabury's documented `openvpn3 session-*` CLI
    openresolv     # applies pushed DNS settings via resolvconf
  ];

  # Ensure the expected directory structure exists with strict permissions
  # so a hand-placed client.conf / auth.txt are not world-readable.
  systemd.tmpfiles.rules = [
    "d /etc/openvpn              0755 root root -"
    "d /etc/openvpn/client       0755 root root -"
    "d /etc/openvpn/client/keys  0700 root root -"
  ];

  # Auto-start the Seabury tunnel on boot once client.conf is present.
  #
  # - ConditionPathExists: unit is a no-op until the admin drops the file.
  # - --auth-nocache: never keep credentials in memory (creds come from the
  #   auth-user-pass file referenced from client.conf).
  # - `--mssfix 1340` approximates the `tun-mtu 1380` guidance from the
  #   Seabury runbook without needing a post-up ip-link hack; Seabury's own
  #   MTU override can still be added to client.conf if needed.
  systemd.services.seabury-vpn = {
    description = "Seabury OpenVPN (auto-start)";
    after       = [ "network-online.target" ];
    wants       = [ "network-online.target" ];
    wantedBy    = [ "multi-user.target" ];

    unitConfig.ConditionPathExists = vpnConf;

    serviceConfig = {
      Type       = "notify";
      ExecStart  = "${pkgs.openvpn}/bin/openvpn --suppress-timestamps --nobind --auth-nocache --config ${vpnConf}";
      Restart    = "on-failure";
      RestartSec = "10s";
      # Allow openvpn to create the tun device and modify routes.
      CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SETUID CAP_SETGID";
      AmbientCapabilities   = "CAP_NET_ADMIN CAP_NET_RAW CAP_SETUID CAP_SETGID";
      ProtectHome           = true;
      ProtectSystem         = "strict";
      ReadWritePaths        = [ "/etc/resolv.conf" "/run" ];
    };
  };

  ##############################################################################
  # RUNBOOK (one-time, per machine — intentionally out-of-band because
  # client.conf and the password are both sensitive):
  #
  # 1. Get `client.conf` from Seabury IT (or gitlab.seaburymro.com) and
  #    place it at the canonical path:
  #
  #       sudo install -m 0600 -o root -g root client.conf \
  #         /etc/openvpn/client/keys/client.conf
  #
  # 2. Append an auth-user-pass line to client.conf so OpenVPN never
  #    prompts interactively (required for unattended auto-start):
  #
  #       echo 'auth-user-pass /etc/openvpn/client/keys/auth.txt' \
  #         | sudo tee -a /etc/openvpn/client/keys/client.conf
  #
  # 3. Create the credential file (username on line 1, password on line 2).
  #    The file must be mode 0600 and owned by root:
  #
  #       sudo install -m 0600 -o root -g root /dev/null \
  #         /etc/openvpn/client/keys/auth.txt
  #       sudoedit /etc/openvpn/client/keys/auth.txt
  #       # <gitlab.seaburymro.com username>
  #       # <password>
  #
  # 4. Enable and start the unit:
  #
  #       sudo systemctl enable --now seabury-vpn.service
  #       journalctl -u seabury-vpn -f
  #
  # Optional — use openvpn3 interactively instead of the auto-start unit:
  #
  #       openvpn3 session-start  --config /etc/openvpn/client/keys/client.conf
  #       openvpn3 session-manage --config /etc/openvpn/client/keys/client.conf --disconnect
  #
  # If you want the credentials managed declaratively, encrypt auth.txt with
  # sops (this repo already imports sops-nix) and point sops.secrets.* at
  # /etc/openvpn/client/keys/auth.txt with mode 0400 / owner root.
  ##############################################################################
}
