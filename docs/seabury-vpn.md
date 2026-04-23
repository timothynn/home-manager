# Seabury VPN — step-by-step setup

This flake wires up the Seabury VPN through the official
[`programs.openvpn3`](https://search.nixos.org/options?query=programs.openvpn3)
NixOS module (enabled in `modules/services/seabury-vpn.nix`).  That
module handles the `openvpn3` binary, its D-Bus services
(`net.openvpn.v3.{configmgr,sessions,log,netcfg}`), and `systemd-resolved`
DNS integration.  **What the module cannot do is ship
`client.conf`** — that file comes from Seabury IT and contains
organisation-specific endpoints, so it lives outside git on each machine.

The steps below take a fresh NixOS machine (post-`nixos-rebuild switch`)
all the way to a connected tunnel.

---

## Prerequisites

- You have already run `sudo nixos-rebuild switch --flake ~/.config/home-manager#default`
  at least once, so `openvpn3` is on `$PATH` and the D-Bus services are up.
  Verify with:
  ```bash
  which openvpn3                 # /run/current-system/sw/bin/openvpn3
  systemctl status openvpn3-autoload.service --no-pager || true
  busctl list | grep openvpn     # expect net.openvpn.v3.*
  ```
- You have a Seabury GitLab account at <https://gitlab.seaburymro.com/>
  with the username/password you'll use for interactive auth.
- You have access to Seabury's `openvpn.tar.gz` profile bundle (your IT
  desk / the onboarding docs on that GitLab instance).

---

## 1. Drop `client.conf` into place

Extract the Seabury bundle into `/etc/openvpn/` — the tarball already
contains the expected `client/keys/client.conf` layout:

```bash
# Adjust the source path to wherever you saved the tarball.
sudo tar -xzf ~/Downloads/openvpn.tar.gz -C /etc/openvpn/

# Lock permissions down so only root can read the config + keys.
sudo chown -R root:root /etc/openvpn
sudo chmod 0700         /etc/openvpn/client/keys
sudo chmod 0600         /etc/openvpn/client/keys/client.conf
```

Sanity-check the layout:

```bash
sudo ls -la /etc/openvpn/client/keys/
# expected: client.conf (0600) and any *.crt / *.pem / ta.key
```

If the tarball is structured differently on your IT team's side, place
the primary profile at `/etc/openvpn/client/keys/client.conf` by hand —
every step below references that exact path.

---

## 2. (Optional) Pin the MTU to 1380

Per Seabury's runbook, a `tun-mtu 1380` line in the profile avoids having
to run `sudo ifconfig tun0 mtu 1380 up` after every connect:

```bash
echo 'tun-mtu 1380' | sudo tee -a /etc/openvpn/client/keys/client.conf
```

Skip this if your bundle already contains a `tun-mtu` line.

---

## 3. Connect (interactive auth)

```bash
openvpn3 session-start \
  --config /etc/openvpn/client/keys/client.conf
```

It will prompt:

```
Auth User name: <your gitlab.seaburymro.com username>
Auth Password:  <your gitlab.seaburymro.com password>
```

A successful connect prints a `Session path:` line and returns.
**No credentials are persisted by the module** — the prompt re-runs on
every `session-start`.  If you want passwordless connects long-term, see
"Cert-based profiles" in `modules/services/seabury-vpn.nix`.

---

## 4. Verify the tunnel is up

```bash
# Active sessions (expect one line with Status: Connected).
openvpn3 sessions-list

# Tunnel interface came up.
ip -o addr show tun0

# Egress IP is Seabury's, not your ISP's.
curl -s https://ifconfig.me && echo
```

If `sessions-list` says `Waiting for authentication` for more than a few
seconds, check the log:

```bash
openvpn3 log --config /etc/openvpn/client/keys/client.conf
```

---

## 5. Disconnect

```bash
openvpn3 session-manage \
  --config /etc/openvpn/client/keys/client.conf \
  --disconnect
```

Or list sessions and kill by path if the config path form doesn't match
for whatever reason:

```bash
openvpn3 sessions-list
openvpn3 session-manage --session-path /net/openvpn/v3/sessions/<id> --disconnect
```

---

## Shell shortcuts

The zsh config in this repo (`home/shell/zsh.nix`) ships three wrappers
so you don't have to retype the config path:

| Alias         | Expansion                                                                  |
| ------------- | -------------------------------------------------------------------------- |
| `vpn-up`      | `openvpn3 session-start --config /etc/openvpn/client/keys/client.conf`     |
| `vpn-down`    | `openvpn3 session-manage --config … --disconnect`                          |
| `vpn-status`  | `openvpn3 sessions-list`                                                   |

These become available on the next login (or `exec zsh`).

---

## Auto-start on boot

**Intentionally not enabled** by this flake.  Seabury's profile requires
interactive credentials, so a boot-time autoload would block on an
unreachable password prompt.

If you move to a cert-based profile (no interactive auth), opt in with:

```bash
sudo openvpn3 config-import \
  --config /etc/openvpn/client/keys/client.conf \
  --persistent

sudo openvpn3 config-manage --config client --prop autoload=true
```

From the next boot onward, `openvpn3-autoload.service` picks it up.

---

## Troubleshooting

- **`Permission denied` on `client.conf`** — the `programs.openvpn3`
  module runs commands as your user; root-owned `0600` files are still
  readable by `session-start` because it hands the path to the privileged
  config manager over D-Bus, not to the CLI process itself.  If you see
  `EACCES`, double-check `/etc/openvpn/client/keys/` is `0700 root:root`
  (not `0755`).
- **DNS breaks after connect** — enable `services.resolved` on the host
  (the module's `netcfg.systemd_resolved` setting is gated on that).
  Without resolved, openvpn3 patches `/etc/resolv.conf` directly and that
  fights with NetworkManager.
- **"no D-Bus session"** — the openvpn3 services are *system* D-Bus, not
  session.  `busctl --system list | grep openvpn` is the right check.
- **Profile contains `auth-user-pass` without a file argument** — the
  CLI will prompt on every connect, which is the default behaviour this
  doc assumes.  If your bundle instead points at
  `auth-user-pass /etc/openvpn/client/keys/auth.txt`, create that file
  with username on line 1 and password on line 2, `0600 root:root`.

---

## Rotating credentials

Devin chat logs are persisted.  If you ever pasted your GitLab password
in a chat (it happens), rotate it at
<https://gitlab.seaburymro.com/-/profile/password/edit>, then you're
done — this flake never stored it anywhere on disk.
