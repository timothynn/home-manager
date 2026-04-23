##############################################################################
# modules/programs/git.nix  [Home Manager module]
#
# Git — declarative configuration with delta as the pager/diff tool.
# Catppuccin Mocha colours applied via catppuccin-nix (delta integration).
#
# Notes on HM option paths used below:
#   - `programs.git.settings.{user,alias,...}` replaces the older
#     `programs.git.{userName,userEmail,aliases,extraConfig}` options (HM
#     rename; old paths still work but emit deprecation warnings).
#   - `programs.delta` is its own top-level module now; `programs.git.delta`
#     has been moved out. `programs.delta.enableGitIntegration = true` is
#     required to wire delta into git's pager.
##############################################################################
{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name  = "timothynn";
        email = "timothynn08@gmail.com";
      };

      alias = {
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
  };

  # delta — external pager / diff tool for git, themed via catppuccin-nix.
  programs.delta = {
    enable               = true;
    enableGitIntegration = true;
    options = {
      navigate     = true;
      light        = false;
      side-by-side = true;
      line-numbers = true;
    };
  };

  # Catppuccin integrations (flavor=mocha, accent=mauve set globally in
  # home/theme/catppuccin.nix). `catppuccin.delta.enable` is a no-op unless
  # `programs.delta.enable` is also true (enabled above).
  catppuccin.delta.enable = true;
}
