##############################################################################
# modules/programs/git.nix  [Home Manager module]
#
# Git — declarative configuration with delta as the pager/diff tool.
# Catppuccin Mocha colours applied via catppuccin-nix (delta integration).
##############################################################################
{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name  = "timothynn";
        email = "timothynn08@gmail.com"; # ← change to your email
      };

      extraConfig = {
        init.defaultBranch = "main";
        core = {
          editor     = "nvim";
          autocrlf   = "input";
          whitespace = "trailing-space,space-before-tab";
        };
        pull.rebase  = true;
        push.default = "current";
        merge.conflictstyle = "diff3";
        diff.colorMoved     = "default";
        rerere.enabled      = true;

        # URL rewriting removed to avoid type mismatch in settings; add manually if needed
      };

      alias = {
        st  = "status -sb";
        lg  = "log --oneline --graph --decorate --all";
        co  = "checkout";
        br  = "branch";
        cp  = "cherry-pick";
        rb  = "rebase";
        unstage = "reset HEAD --";
        undo    = "reset --soft HEAD~1";
        wip     = "commit -am 'WIP'";
      };

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

  # delta — external pager / diff tool for git
  programs.delta = {
    enable = true;
    options = {
      navigate          = true;
      light             = false;
      side-by-side      = true;
      line-numbers      = true;
      syntax-theme      = "Catppuccin-mocha";
      plus-style        = "syntax \"#a6e3a1\""; # Catppuccin green
      minus-style       = "syntax \"#f38ba8\""; # Catppuccin red
      map-styles        = "bold purple => syntax \"#cba6f7\", bold cyan => syntax \"#89dceb\"";
    };
  };

  programs.lazygit = {
    enable   = true;
    settings = {
      gui = {
        theme = {
          lightTheme               = false;
          activeBorderColor        = [ "cyan" "bold" ];
          inactiveBorderColor      = [ "white" ];
          selectedLineBgColor      = [ "default" ];
        };
      };
    };
  };
}
