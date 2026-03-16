##############################################################################
# home/shell/starship.nix  [Home Manager module]
#
# Starship prompt — minimal, fast, Catppuccin Mocha colour palette.
# Custom Catppuccin palette is declared inline and used for all segments.
##############################################################################
{ ... }:

{
  programs.starship = {
    enable                = true;
    enableZshIntegration  = true;

    settings = {
      # ── Global ──────────────────────────────────────────────────────────
      add_newline = true;
      palette     = "catppuccin_mocha";

      format = ''
        $os$username$hostname$directory$git_branch$git_status$python$rust$nodejs$golang$nix_shell$cmd_duration$line_break$character'';

      # ── Segments ────────────────────────────────────────────────────────
      character = {
        success_symbol = "[❯](bold mauve)";
        error_symbol   = "[❯](bold red)";
        vimcmd_symbol  = "[❮](bold green)";
      };

      directory = {
        style            = "bold blue";
        truncation_length = 4;
        truncate_to_repo = false;
        read_only        = " 󰌾";
      };

      git_branch = {
        symbol = " ";
        style  = "bold mauve";
        format = "on [$symbol$branch(:$remote_branch)]($style) ";
      };

      git_status = {
        style   = "bold peach";
        format  = "([$all_status$ahead_behind]($style) )";
        ahead   = "⇡\${count}";
        behind  = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        modified = "!";
        staged   = "+";
        deleted  = "✘";
        untracked = "?";
      };

      python = {
        symbol = " ";
        style  = "bold yellow";
        format = "via [$symbol$version]($style) ";
      };

      rust = {
        symbol = " ";
        style  = "bold peach";
        format = "via [$symbol$version]($style) ";
      };

      nodejs = {
        symbol = " ";
        style  = "bold green";
        format = "via [$symbol$version]($style) ";
      };

      golang = {
        symbol = " ";
        style  = "bold sky";
        format = "via [$symbol$version]($style) ";
      };

      nix_shell = {
        symbol   = " ";
        style    = "bold blue";
        impure_msg   = "[impure](bold red)";
        pure_msg     = "[pure](bold green)";
        unknown_msg  = "[unknown](bold yellow)";
        format   = "via [$symbol$state( \\($name\\))]($style) ";
      };

      cmd_duration = {
        style  = "bold yellow";
        format = "took [$duration]($style) ";
        min_time = 2000;
      };

      os = {
        disabled = false;
        style    = "bold text";
        symbols  = {
          NixOS = " ";
          Linux = " ";
        };
      };

      username = {
        style_user = "bold lavender";
        style_root = "bold red";
        format     = "[$user]($style) ";
        show_always = false;
      };

      hostname = {
        style      = "bold sapphire";
        format     = "[@$hostname]($style) ";
        ssh_only   = true;
      };

      # ── Catppuccin Mocha palette ─────────────────────────────────────────
      palettes.catppuccin_mocha = {
        rosewater  = "#f5e0dc";
        flamingo   = "#f2cdcd";
        pink       = "#f5c2e7";
        mauve      = "#cba6f7";
        red        = "#f38ba8";
        maroon     = "#eba0ac";
        peach      = "#fab387";
        yellow     = "#f9e2af";
        green      = "#a6e3a1";
        teal       = "#94e2d5";
        sky        = "#89dceb";
        sapphire   = "#74c7ec";
        blue       = "#89b4fa";
        lavender   = "#b4befe";
        text       = "#cdd6f4";
        subtext1   = "#bac2de";
        subtext0   = "#a6adc8";
        overlay2   = "#9399b2";
        overlay1   = "#7f849c";
        overlay0   = "#6c7086";
        surface2   = "#585b70";
        surface1   = "#45475a";
        surface0   = "#313244";
        base       = "#1e1e2e";
        mantle     = "#181825";
        crust      = "#11111b";
      };
    };
  };
}
