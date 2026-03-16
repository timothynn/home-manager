{ pkgs, config, ... }:

let
  syncScript = pkgs.writeShellApplication {
    name = "dotfiles-sync";
    runtimeInputs = with pkgs; [ git coreutils gnugrep gnused openssh ];
    text = ''
      set -euo pipefail

      REPO="$HOME/.config/home-manager"
      BRANCH="main"

      if [ ! -d "$REPO/.git" ]; then
        echo "dotfiles-sync: $REPO is not a git repository"
        exit 0
      fi

      cd "$REPO"

      if git remote get-url origin >/dev/null 2>&1; then
        git pull --rebase --autostash origin "$BRANCH" || true
      fi

      if [ -n "$(git status --porcelain)" ]; then
        git add -A
        git commit -m "chore(dotfiles): auto-sync $(date -Iseconds)" || true
        git push origin "$BRANCH" || true
      fi
    '';
  };
in
{
  home.packages = [ syncScript ];

  systemd.user.services.dotfiles-autosync = {
    Unit = {
      Description = "Auto-sync Home Manager dotfiles to GitHub";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${syncScript}/bin/dotfiles-sync";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.timers.dotfiles-autosync = {
    Unit.Description = "Run dotfiles auto-sync every 30 minutes";
    Timer = {
      OnBootSec = "5m";
      OnUnitActiveSec = "30m";
      Unit = "dotfiles-autosync.service";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
