##############################################################################
# modules/services/seabury-vpn.nix
#
# Seabury VPN client, matching the official Seabury runbook (OpenVPN 3 CLI):
#
#   openvpn3 session-start  --config /etc/openvpn/client/keys/client.conf
#   openvpn3 session-manage --config /etc/openvpn/client/keys/client.conf \
#                           --disconnect
#
# Auth is interactive — when `session-start` prompts, use your
# https://gitlab.seaburymro.com/ username + password. No credentials are
# persisted by this module.
#
# Wiring notes
# ------------
# This module enables the upstream `programs.openvpn3` NixOS module
# (nixos/modules/programs/openvpn3.nix), which:
#   - installs `pkgs.openvpn3` system-wide
#   - starts the OpenVPN 3 D-Bus services:
#       net.openvpn.v3.configmgr
#       net.openvpn.v3.sessions
#       net.openvpn.v3.log
#       net.openvpn.v3.netcfg
#   - integrates with systemd-resolved when available
#
# No bespoke systemd unit is needed — openvpn3 coordinates via D-Bus, not
# a long-lived daemon.
#
# This module does NOT ship `client.conf`. That file is provided by
# Seabury IT (gitlab.seaburymro.com → openvpn.tar.gz). See the RUNBOOK
# at the bottom of this file for the one-time placement steps.
##############################################################################
{ config, ... }:

{
  # Upstream NixOS module: installs openvpn3 and wires its D-Bus + systemd
  # integration. Option docs: https://search.nixos.org → programs.openvpn3.
  programs.openvpn3.enable = true;

  # Use systemd-resolved DNS integration only when resolved is actually
  # running on this host; otherwise openvpn3 logs resolved errors on every
  # session-start.
  programs.openvpn3.netcfg.settings.systemd_resolved =
    config.services.resolved.enable;

  # Expected directory structure with strict permissions so a hand-placed
  # client.conf is never world-readable.
  systemd.tmpfiles.rules = [
    "d /etc/openvpn              0755 root root -"
    "d /etc/openvpn/client       0755 root root -"
    "d /etc/openvpn/client/keys  0700 root root -"
  ];

  ##############################################################################
  # RUNBOOK (one-time, per machine — intentionally out-of-band because
  # client.conf is sensitive and provided by Seabury IT):
  #
  # 1. Obtain `openvpn.tar.gz` from Seabury IT (or gitlab.seaburymro.com
  #    per the installation docs) onto your machine, e.g. ~/Downloads/.
  #
  # 2. Extract its contents into /etc/openvpn/ — the tarball already
  #    contains the `client/keys/client.conf` layout the runbook uses:
  #
  #        sudo tar -xzf ~/Downloads/openvpn.tar.gz -C /etc/openvpn/
  #        sudo chown -R root:root /etc/openvpn
  #        sudo chmod 0700 /etc/openvpn/client/keys
  #        sudo chmod 0600 /etc/openvpn/client/keys/client.conf
  #
  # 3. (Optional) Pin MTU to 1380 per Seabury IT — saves running
  #    `sudo ifconfig tun0 mtu 1380 up` after every session-start:
  #
  #        echo 'tun-mtu 1380' | sudo tee -a \
  #            /etc/openvpn/client/keys/client.conf
  #
  # 4. Connect (auth interactively with gitlab.seaburymro.com creds):
  #
  #        openvpn3 session-start \
  #            --config /etc/openvpn/client/keys/client.conf
  #        # Auth User name: <gitlab username>
  #        # Auth Password:  <gitlab password>
  #
  #    Sanity checks:
  #
  #        openvpn3 sessions-list
  #        ip -o addr show tun0
  #        curl -s https://ifconfig.me    # should be a Seabury egress IP
  #
  # 5. Disconnect:
  #
  #        openvpn3 session-manage \
  #            --config /etc/openvpn/client/keys/client.conf \
  #            --disconnect
  #
  # 6. Shell shortcuts: `vpn-up`, `vpn-down`, `vpn-status` are defined in
  #    home/shell/zsh.nix.
  #
  # Auto-start on boot (intentionally NOT enabled here)
  # ---------------------------------------------------
  # openvpn3 has a native autoload mechanism (openvpn3-autoload). Because
  # Seabury's client.conf requires interactive credentials, enabling
  # autoload today would cause session-start to block at boot on an auth
  # prompt that never comes. If you later switch to a cert-based profile,
  # you can opt in manually with:
  #
  #        sudo openvpn3 config-import \
  #            --config /etc/openvpn/client/keys/client.conf \
  #            --persistent
  #        sudo openvpn3 config-manage --config client \
  #            --prop autoload=true
  ##############################################################################
}
