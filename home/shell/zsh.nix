##############################################################################
# home/shell/zsh.nix  [Home Manager module]
#
# Zsh with Oh-My-Zsh, autosuggestions, syntax highlighting, fast completion,
# and Catppuccin syntax-highlighting colours via catppuccin-nix.
# The prompt is handled by Starship (see home/shell/starship.nix).
##############################################################################
{ config, ... }:

{
  # catppuccin-nix option path for zsh-syntax-highlighting is the top-level
  # `catppuccin.zsh-syntax-highlighting.enable` (guarded by
  # `programs.zsh.syntaxHighlighting.enable` below).
  catppuccin.zsh-syntax-highlighting.enable = true;

  # Oh-My-Zsh's `docker` and `kubectl` plugins are REMOVED from the plugin
  # list below. Both copy their CLI's completion into
  # `$ZSH_CACHE_DIR/completions/` at first shell start, and under HM
  # `$ZSH_CACHE_DIR` defaults to `$ZSH/cache` (read-only Nix store) with a
  # fallback to `~/.cache/oh-my-zsh/`. If that fallback dir was ever
  # created or touched by a root-running shell (e.g. `sudo zsh`), the
  # unprivileged plugin run later fails with:
  #   cp: cannot create regular file '/home/tim/.cache/oh-my-zsh/completions/_docker': Permission denied
  # A user-run `mkdir -p` activation can't fix a root-owned subtree.
  #
  # This is redundant on NixOS anyway — `pkgs.docker` and `pkgs.kubectl`
  # both ship their zsh completions under
  # `$out/share/zsh/site-functions/`, which `programs.zsh.enableCompletion`
  # pulls into `fpath` automatically. The OMZ plugin duplicates that
  # work and only adds the permission bug.
  #
  # The previously-added activation script that pre-created
  # `~/.cache/oh-my-zsh/completions` is dropped for the same reason —
  # nothing uses that directory now, so there is nothing to ensure.

  programs.zsh = {
    enable              = true;
    dotDir              = "${config.home.homeDirectory}/.config/zsh";
    autosuggestion.enable  = true;
    enableCompletion    = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable  = true;
      plugins = [
        "git"
        "sudo"
        "z"
        # "docker"   — removed: pkgs.docker ships `_docker` into fpath via
        #              `$out/share/zsh/site-functions/`; OMZ's plugin only
        #              duplicates that and triggers the ~/.cache/oh-my-zsh
        #              permission-denied bug documented above.
        # "kubectl"  — removed: same story for pkgs.kubectl.
        "fzf"
        "colored-man-pages"
      ];
    };

    shellAliases = {
      # Navigation
      ls  = "eza --icons --color=always --group-directories-first";
      ll  = "eza -lah --icons --color=always --group-directories-first";
      lt  = "eza --tree --icons --color=always --level=3";
      ".." = "cd ..";

      # Editor
      v   = "nvim";
      vim = "nvim";

      # Git shortcuts
      g   = "git";
      lg  = "lazygit";

      # Better defaults
      cat = "bat --style=plain";
      grep = "rg";
      find = "fd";
      du   = "dust";
      top  = "btm";
      ps   = "procs";

      # Nix
      hms  = "home-manager switch --flake ~/.config/home-manager#tim";
      nrs  = "sudo nixos-rebuild switch --flake ~/.config/home-manager#default";
      nfu  = "nix flake update";
      nco  = "nix-collect-garbage -d";

      # Seabury VPN (OpenVPN 3). See modules/services/seabury-vpn.nix for
      # the one-time runbook. `vpn-up` prompts interactively for the
      # gitlab.seaburymro.com username + password.
      vpn-up     = "openvpn3 session-start --config /etc/openvpn/client/keys/client.conf";
      vpn-down   = "openvpn3 session-manage --config /etc/openvpn/client/keys/client.conf --disconnect";
      vpn-status = "openvpn3 sessions-list";

      # Misc
      cls  = "clear";
      q    = "exit";
      path = "echo $PATH | tr ':' '\\n'";
    };

    initContent = ''
      # Starship is initialised by programs.starship.enableZshIntegration
      # zoxide is initialised by programs.zoxide.enableZshIntegration

      # Better history
      HISTSIZE=100000
      SAVEHIST=100000
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_SAVE_NO_DUPS
      setopt HIST_FIND_NO_DUPS
      setopt SHARE_HISTORY
      setopt EXTENDED_HISTORY

      # Directory options
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS

      # FZF-zoxide integration
      eval "$(zoxide init zsh --cmd cd)"
    '';
  };
}
