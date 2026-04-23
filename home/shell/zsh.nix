##############################################################################
# home/shell/zsh.nix  [Home Manager module]
#
# Zsh with Oh-My-Zsh, autosuggestions, syntax highlighting, fast completion,
# and Catppuccin syntax-highlighting colours via catppuccin-nix.
# The prompt is handled by Starship (see home/shell/starship.nix).
##############################################################################
{ pkgs, config, ... }:

{
  programs.zsh = {
    enable              = true;
    dotDir              = "${config.home.homeDirectory}/.config/zsh";
    autosuggestion.enable  = true;
    enableCompletion    = true;
    syntaxHighlighting = {
      enable             = true;
      catppuccin.enable  = true;
    };

    oh-my-zsh = {
      enable  = true;
      plugins = [
        "git"
        "sudo"
        "z"
        "docker"
        "kubectl"
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
