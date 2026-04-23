##############################################################################
# modules/programs/git.nix  [Home Manager module]
#
# Git — declarative configuration with delta as the pager/diff tool.
# Catppuccin Mocha colours applied via catppuccin-nix (delta integration).
##############################################################################
{ ... }:

{
  # Home Manager's `programs.git` does not have a `settings` attribute — user /
  # email / aliases / extraConfig / ignores are top-level options. The previous
  # shape nested everything under `settings = {…}` which fails to evaluate.
  programs.git = {
    enable    = true;
    userName  = "timothynn";
    userEmail = "timothynn08@gmail.com";

    aliases = {
      st      = "status -sb";
      lg      = "log --oneline --graph --decorate --all";
      co      = "checkout";
      br      = "branch";
      cp      = "cherry-pick";
      rb      = "rebase";
      unstage = "reset HEAD --";
      undo    = "reset --soft HEAD~1";
      wip     = "commit -am 'WIP'";
    };

    extraConfig = {
      init.defaultBranch  = "main";
      core = {
        editor     = "nvim";
        autocrlf   = "input";
        whitespace = "trailing-space,space-before-tab";
      };
      pull.rebase         = true;
      push.default        = "current";
      merge.conflictstyle = "diff3";
      diff.colorMoved     = "default";
      rerere.enabled      = true;
    };

    ignores = [
      ".DS_Store"
      "*.swp"
      ".direnv"
      ".envrc"
      "result"
      "result-*"
    ];

    # delta — external pager / diff tool for git, themed via catppuccin-nix.
    delta = {
      enable = true;
      options = {
        navigate     = true;
        light        = false;
        side-by-side = true;
        line-numbers = true;
      };
    };
  };

  # Catppuccin integrations (flavor=mocha, accent=mauve set globally in
  # home/theme/catppuccin.nix).
  programs.git.delta.catppuccin.enable = true;
}
