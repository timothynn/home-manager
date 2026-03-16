##############################################################################
# home/shell/cli-tools.nix  [Home Manager module]
#
# Modern CLI developer tooling — all configured declaratively.
# Catppuccin theming applied via catppuccin-nix where supported.
##############################################################################
{ pkgs, ... }:

{
  # ── Packages without dedicated HM options ─────────────────────────────────
  home.packages = with pkgs; [
    ripgrep          # rg  — fast regex search
    fd               # fd  — fast find replacement
    dust             # dust — intuitive du replacement
    bottom           # btm  — system monitor (process / resource viewer)
    hyperfine        # benchmark runner
    tokei            # count lines of code
    just             # command runner (Makefile alternative)
    gitui            # TUI git client (alternative to lazygit)
    sd               # sed replacement
    bandwhich        # network utilisation by process
    procs            # ps replacement
    jq               # JSON processor
    yq               # YAML/TOML/XML processor
    tealdeer         # tldr pages (fast Rust impl)
    navi             # cheatsheet tool
    xh               # HTTPie-like HTTP client
    glow             # Markdown renderer for the terminal
    difftastic       # structural diff tool

    # DNS lookup tool (dog replacement)
    doggo

    # Keep `dog` command compatibility.
    (writeShellScriptBin "dog" ''
      exec ${doggo}/bin/doggo "$@"
    '')
  ];

  # ── bat — cat with syntax highlighting ─────────────────────────────────────
  programs.bat = {
    enable            = true;
    config = {
      theme       = "Catppuccin Mocha";
      style       = "numbers,changes,header";
      pager       = "less -FR";
    };
  };

  # ── fzf — fuzzy finder ─────────────────────────────────────────────────────
  programs.fzf = {
    enable                = true;
    enableZshIntegration  = true;
    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border=rounded"
      "--info=inline"
      "--prompt=  "
      "--pointer=  "
      "--marker=  "
    ];
  };

  # ── zoxide — smart cd ──────────────────────────────────────────────────────
  programs.zoxide = {
    enable               = true;
    enableZshIntegration = true;
  };

  # ── atuin — shell history with sync ────────────────────────────────────────
  programs.atuin = {
    enable               = true;
    enableZshIntegration = true;
    settings = {
      auto_sync         = true;
      update_check      = false;
      style             = "compact";
      show_preview      = true;
      filter_mode_shell_up_key = "session";
    };
  };

  # ── eza — modern ls replacement ────────────────────────────────────────────
  programs.eza = {
    enable            = true;
    icons             = "auto";
    git               = true;
    extraOptions = [
      "--group-directories-first"
      "--color=always"
    ];
  };

  # ── yazi — terminal file manager ───────────────────────────────────────────
  programs.yazi = {
    enable               = true;
    enableZshIntegration = true;
    settings = {
      manager = {
        ratio         = [ 1 4 3 ];
        show_hidden   = false;
        show_symlink  = true;
        sort_by       = "natural";
        sort_dir_first = true;
      };
      shellWrapperName = "yy";
    };
  };

  # ── zellij — terminal multiplexer ──────────────────────────────────────────
  programs.zellij = {
    enable               = true;
  };

  # ── fastfetch — system info fetcher ────────────────────────────────────────
  programs.fastfetch = {
    enable = true;
    settings = {
      logo.source = "nixos";
      display = {
        separator = "  ";
        color.separator = "blue";
      };
      modules = [
        "title" "separator" "os" "host" "kernel" "uptime"
        "packages" "shell" "display" "de" "wm" "terminal"
        "cpu" "gpu" "memory" "swap" "disk" "battery"
      ];
    };
  };

  # ── lazygit ─────────────────────────────────────────────────────────────────
  programs.lazygit.enable = true;

  # ── skim — alternative fzf ──────────────────────────────────────────────────
  programs.skim.enable = true;

  # ── cava — audio visualiser ─────────────────────────────────────────────────
  programs.cava = {
    enable = true;
    settings = {
      color = {
        gradient       = 1;
        gradient_count = 8;
        # Catppuccin Mocha gradient: teal → sky → sapphire → blue → lavender → mauve → pink → red
        gradient_color_1 = "'#94e2d5'";
        gradient_color_2 = "'#89dceb'";
        gradient_color_3 = "'#74c7ec'";
        gradient_color_4 = "'#89b4fa'";
        gradient_color_5 = "'#b4befe'";
        gradient_color_6 = "'#cba6f7'";
        gradient_color_7 = "'#f5c2e7'";
        gradient_color_8 = "'#f38ba8'";
      };
    };
  };
}
