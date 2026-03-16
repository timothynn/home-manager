{ pkgs, ... }:

let
  rofiTheme = pkgs.writeText "rofi-catppuccin-mocha.rasi" ''
    * {
      bg0: #11111b;
      bg1: #1e1e2e;
      bg2: #313244;
      fg0: #cdd6f4;
      fg1: #bac2de;
      accent: #cba6f7;
      ok: #a6e3a1;
      warn: #f9e2af;
      err: #f38ba8;

      font: "JetBrainsMono Nerd Font 12";
      border-radius: 12px;
    }

    window {
      width: 640px;
      border: 2px;
      border-color: @accent;
      background-color: @bg1;
    }

    mainbox {
      spacing: 8px;
      padding: 14px;
      background-color: transparent;
    }

    inputbar {
      spacing: 10px;
      padding: 10px;
      border: 0 0 2px 0;
      border-color: @bg2;
      text-color: @fg0;
      background-color: @bg0;
    }

    listview {
      lines: 10;
      columns: 1;
      fixed-height: false;
      spacing: 4px;
      background-color: transparent;
    }

    element {
      padding: 10px;
      border-radius: 10px;
      text-color: @fg1;
      background-color: transparent;
    }

    element selected {
      text-color: @bg1;
      background-color: @accent;
    }

    prompt {
      text-color: @accent;
    }

    entry {
      text-color: @fg0;
      placeholder: "Search";
      placeholder-color: @fg1;
    }
  '';
in
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    terminal = "kitty";
    font = "JetBrainsMono Nerd Font 12";
    theme = "${rofiTheme}";
    extraConfig = {
      "show-icons" = true;
      "icon-theme" = "Papirus-Dark";
      modi = "drun,run,window,filebrowser";
      "drun-display-format" = "{name}";
      "display-drun" = "Apps";
      "display-run" = "Run";
      "display-window" = "Windows";
      "display-filebrowser" = "Files";
      "kb-row-select" = "Tab";
      "kb-row-tab" = "Control+i";
      "kb-mode-next" = "Control+space";
    };
  };
}
