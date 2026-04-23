{ pkgs, ... }:

let
  # Rofi's rasi cascade is partial: unless you start from `@theme "/dev/null"`
  # and style every widget, rofi's compiled-in default leaks through and
  # paints borders/backgrounds on widgets you didn't touch. The previous
  # theme only styled `window / mainbox / inputbar / listview / element /
  # prompt / entry` — leaving `element-icon` (white background ring around
  # every app icon), `element-text` (stray padding), and the per-state
  # variants (`element normal.normal`, `element alternate.normal`, etc.)
  # at their built-in defaults. That's what produced the "white pill per
  # row + white halo around every icon" look in the bug screenshot.
  #
  # Fix: inherit from /dev/null (empty base theme) and style every widget
  # rofi actually renders. Colors stay Catppuccin Mocha; everything else
  # is either `transparent`, `border: 0;`, or an explicit Catppuccin value.
  rofiTheme = pkgs.writeText "rofi-catppuccin-mocha.rasi" ''
    @theme "/dev/null"

    * {
      bg0:     #11111b;
      bg1:     #1e1e2e;
      bg1-alt: #181825;
      bg2:     #313244;
      fg0:     #cdd6f4;
      fg1:     #bac2de;
      accent:  #cba6f7;
      ok:      #a6e3a1;
      warn:    #f9e2af;
      err:     #f38ba8;

      font: "JetBrainsMono Nerd Font 12";
      border-radius: 12px;

      background-color: transparent;
      text-color:       @fg0;
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
      children: [ "inputbar", "listview" ];
    }

    inputbar {
      spacing: 10px;
      padding: 10px;
      border: 0 0 2px 0;
      border-color: @bg2;
      background-color: @bg0;
      children: [ "prompt", "entry" ];
    }

    prompt {
      padding: 0 8px 0 0;
      text-color: @accent;
    }

    entry {
      placeholder:       "Search";
      placeholder-color: @fg1;
      text-color:        @fg0;
      cursor:            text;
    }

    listview {
      lines:        10;
      columns:      1;
      fixed-height: false;
      scrollbar:    false;
      spacing:      4px;
      padding:      4px 0 0 0;
      cycle:        true;
      dynamic:      true;
    }

    /* element's base styling — every variant (normal/alternate/selected
       × normal/urgent/active) inherits from here unless overridden. The
       explicit `border: 0;` is what kills the stray white outline on
       each row that was visible in the bug screenshot. */
    element {
      padding:       8px 10px;
      spacing:       10px;
      border:        0;
      border-radius: 10px;
      cursor:        pointer;
      children:      [ "element-icon", "element-text" ];
    }

    element normal.normal,
    element alternate.normal {
      background-color: transparent;
      text-color:       @fg1;
    }

    element selected.normal {
      background-color: @accent;
      text-color:       @bg1;
    }

    element normal.urgent,
    element alternate.urgent {
      background-color: transparent;
      text-color:       @err;
    }

    element selected.urgent {
      background-color: @err;
      text-color:       @bg1;
    }

    element normal.active,
    element alternate.active {
      background-color: transparent;
      text-color:       @ok;
    }

    element selected.active {
      background-color: @ok;
      text-color:       @bg1;
    }

    /* Icon slot — no background, no border, fixed size so rows stay
       aligned. Without these explicit lines rofi's default paints a
       white square/ring behind every SVG icon. */
    element-icon {
      size:             28px;
      background-color: transparent;
      text-color:       inherit;
      vertical-align:   0.5;
    }

    element-text {
      background-color: transparent;
      text-color:       inherit;
      vertical-align:   0.5;
      highlight:        bold underline;
    }

    /* Hidden widgets rofi still sizes — keep them transparent so they
       don't punch a hole in the background. */
    message, textbox-prompt-colon, case-indicator, num-rows,
    num-filtered-rows, mode-switcher {
      background-color: transparent;
      text-color:       @fg1;
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

      # No `kb-*` overrides here. Rofi's stock defaults already form a
      # non-colliding set (Tab=next row, Return=accept, Shift+Right/Left
      # for mode switching, Control+Tab/Control+Shift+Tab for mode-next/
      # previous). Every earlier override we tried here collided with
      # another default because Nix attrsets serialise alphabetically —
      # rofi parses `kb-row-select` before `kb-row-tab`, so setting
      # `kb-row-select = "Tab"` races against kb-row-tab's default (also
      # `Tab`) and fails with `Binding \`Tab\` is already bound`.
      # If any binding *must* be re-customised, look up the live defaults
      # with `rofi -dump-config` first to avoid alphabetical parse-order
      # collisions.
    };
  };
}
