##############################################################################
# home/desktop/hyprland.nix  [Home Manager module]
#
# Per-user Hyprland configuration: decorations, animations, keybinds, rules.
# The system-level service enablement is in modules/desktop/hyprland.nix.
##############################################################################
{ pkgs, config, inputs ? {}, ... }:

let
  # Catppuccin Mocha palette (hex without #, for use in ARGB rgba strings)
  mocha = {
    base     = "1e1e2e";
    mantle   = "181825";
    surface0 = "313244";
    surface1 = "45475a";
    text     = "cdd6f4";
    mauve    = "cba6f7";
    blue     = "89b4fa";
    sapphire = "74c7ec";
    green    = "a6e3a1";
    red      = "f38ba8";
    peach    = "fab387";
    yellow   = "f9e2af";
    pink     = "f5c2e7";
  };
in
{
  wayland.windowManager.hyprland = {
    enable  = true;
    package = if (builtins.hasAttr "hyprland" inputs)
              then inputs.hyprland.packages.${pkgs.system}.hyprland
              else pkgs.hyprland;

    settings = {
      # ── Monitor ─────────────────────────────────────────────────────────
      monitor = ",preferred,auto,1";

      # ── Autostart ───────────────────────────────────────────────────────
      exec-once = [
        "hyprpaper"
        "waybar"
        "mako"
        "hypridle"
        "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
        "${pkgs.blueman}/bin/blueman-applet"
        "hyprctl setcursor catppuccin-mocha-dark-cursors 24"
      ];

      # ── Environment variables ────────────────────────────────────────────
      env = [
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,catppuccin-mocha-dark-cursors"
        "GDK_SCALE,1"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
      ];

      # ── General ─────────────────────────────────────────────────────────
      general = {
        gaps_in             = 5;
        gaps_out            = 10;
        border_size         = 2;
        "col.active_border" = "rgba(${mocha.mauve}ff) rgba(${mocha.blue}ff) 45deg";
        "col.inactive_border" = "rgba(${mocha.surface0}aa)";
        layout              = "dwindle";
        allow_tearing       = false;
        resize_on_border    = true;
      };

      # ── Decoration (blur + shadows + rounded corners) ────────────────────
      decoration = {
        rounding = 12;

        blur = {
          enabled       = true;
          size          = 8;
          passes        = 2;
          new_optimizations = true;
          popups        = true;
          popups_ignorealpha = 0.2;
        };

        shadow = {
          enabled      = true;
          range        = 10;
          render_power = 3;
          color        = "rgba(0a0a0fcc)";
        };

        # Slight dim on inactive windows
        dim_inactive   = true;
        dim_strength   = 0.06;
      };

      # ── Animations ──────────────────────────────────────────────────────
      animations = {
        enabled = true;

        bezier = [
          "overshot,    0.05, 0.9,  0.1, 1.05"
          "smoothOut,   0.5,  0.0,  0.99, 0.99"
          "smoothIn,    0.5, -0.5,  0.68, 1.5"
          "linear,      0.0,  0.0,  1.0,  1.0"
          "snap,        0.25, 1.0,  0.5,  1.0"
        ];

        animation = [
          "windowsIn,   1, 5, overshot,  slide"
          "windowsOut,  1, 4, smoothOut, slide"
          "windowsMove, 1, 4, smoothIn,  slide"
          "border,      1, 5, default"
          "borderangle, 1, 8, linear,    loop"
          "fade,        1, 7, default"
          "workspaces,  1, 5, overshot"
          "specialWorkspace, 1, 4, overshot, fade"
        ];
      };

      # ── Input ────────────────────────────────────────────────────────────
      input = {
        kb_layout = "us";
        follow_mouse  = 1;
        accel_profile = "flat";
        sensitivity   = 0;
        touchpad = {
          natural_scroll   = true;
          clickfinger_behavior = true;
          tap-to-click     = true;
        };
      };

      # ── Gestures (3-finger horizontal swipes -> workspace left/right) ─────
      # Hyprland 0.51+ replaced the old `workspace_swipe*` options with the
      # 1:1 trackpad `gesture = fingers, direction, action, options` syntax.
      # See https://wiki.hypr.land/Configuring/Gestures/
      gesture = [
        "3, horizontal, workspace"
      ];

      # ── Layouts ──────────────────────────────────────────────────────────
      dwindle = {
        pseudotile     = true;
        preserve_split = true;
        smart_split    = true;
      };

      master = {
        new_status = "slave";
      };

      # ── Misc ─────────────────────────────────────────────────────────────
      misc = {
        force_default_wallpaper   = 0;
        disable_hyprland_logo     = true;
        disable_splash_rendering  = true;
        animate_manual_resizes    = true;
        enable_swallow            = true;
        swallow_regex             = "^(kitty|Alacritty)$";
      };

      # ── Variables ────────────────────────────────────────────────────────
      "$mod"      = "SUPER";
      "$terminal" = "kitty";
      "$browser"  = "firefox";
      "$launcher" = "rofi -show drun";
      "$filemanager" = "nautilus";
      "$dropdown" = "kitty --class dropdown-term --title dropdown-terminal";

      # ── Keybinds ─────────────────────────────────────────────────────────
      bind = [
        # Applications
        "$mod, Return, exec, $terminal"
        "$mod, grave,  exec, $dropdown"
        "$mod, B,      exec, $browser"
        "$mod, SPACE,  exec, $launcher"
        "$mod, E,      exec, $filemanager"

        # Window management
        "$mod, Q,      killactive"
        "$mod, M,      exit"
        "$mod, V,      togglefloating"
        "$mod, F,      fullscreen"
        "$mod, P,      pseudo"
        # T = Toggle split for dwindle layout (avoids conflict with $mod, j = movefocus, d)
        "$mod, T,      layoutmsg, togglesplit"
        "$mod SHIFT, F, togglefloating"

        # Focus
        "$mod, left,  movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up,    movefocus, u"
        "$mod, down,  movefocus, d"
        "$mod, h,     movefocus, l"
        "$mod, l,     movefocus, r"
        "$mod, k,     movefocus, u"
        "$mod, j,     movefocus, d"

        # Move windows
        "$mod SHIFT, left,  movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up,    movewindow, u"
        "$mod SHIFT, down,  movewindow, d"
        "$mod SHIFT, h,     movewindow, l"
        "$mod SHIFT, l,     movewindow, r"
        "$mod SHIFT, k,     movewindow, u"
        "$mod SHIFT, j,     movewindow, d"

        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Scratchpad
        "$mod, S,       togglespecialworkspace, magic"
        "$mod SHIFT, D, movetoworkspace, special:magic"
        "$mod, apostrophe, togglespecialworkspace, dropdown"
        "$mod SHIFT, apostrophe, movetoworkspace, special:dropdown"

        # Scroll through workspaces
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up,   workspace, e-1"

        # Screenshots — grim/slurp (raw)
        ",      Print, exec, grim -g \"$(slurp -d)\" - | wl-copy"
        "SHIFT, Print, exec, mkdir -p ~/Pictures/screenshots && grim ~/Pictures/screenshots/$(date +'%F_%T').png"
        "$mod,  Print, exec, mkdir -p ~/Pictures/screenshots && grim ~/Pictures/screenshots/$(date +'%F_%T').png"

        # Screenshots — hyprshot (region / window / monitor)
        "$mod SHIFT, Print, exec, hyprshot -m region --clipboard-only"
        "$mod CTRL,  Print, exec, hyprshot -m window --clipboard-only"
        "$mod ALT,   Print, exec, hyprshot -m output --clipboard-only"
        # Save to ~/Pictures/screenshots/ (no clipboard)
        "$mod SHIFT, S, exec, mkdir -p ~/Pictures/screenshots && hyprshot -m region -o ~/Pictures/screenshots"
        "$mod SHIFT, P, exec, mkdir -p ~/Pictures/screenshots && hyprshot -m window -o ~/Pictures/screenshots"
        "$mod SHIFT, M, exec, mkdir -p ~/Pictures/screenshots && hyprshot -m output -o ~/Pictures/screenshots"

        # Lock
        "$mod, L, exec, hyprlock"

        # Clipboard
        "$mod, C, exec, wl-copy"
      ];

      # Mouse binds
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Media keys (repeat-able)
      bindel = [
        ", XF86AudioRaiseVolume,   exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume,   exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp,    exec, brightnessctl set 10%+"
        ", XF86MonBrightnessDown,  exec, brightnessctl set 10%-"
      ];

      # Non-repeat media keys
      bindl = [
        ", XF86AudioMute,    exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay,    exec, playerctl play-pause"
        ", XF86AudioPrev,    exec, playerctl previous"
        ", XF86AudioNext,    exec, playerctl next"
        ", XF86AudioStop,    exec, playerctl stop"
      ];

      # ── Window rules ─────────────────────────────────────────────────────
      # Hyprland 0.53+ `windowrule` grammar: RULE first, match conditions
      # after as `key:value` pairs. Booleans (`float`, `pin`) are rules
      # on their own — no trailing `on`. `suppressevent` is one word.
      # See https://wiki.hypr.land/Configuring/Window-Rules/
      windowrule = [
        # Suppress unwanted maximize requests from apps
        "suppressevent maximize, class:.*"

        # Float common utility windows
        "float, class:^(pavucontrol)$"
        "float, class:^(blueman-manager)$"
        "float, class:^(nm-connection-editor)$"
        "float, title:^(Picture-in-Picture)$"
        "float, class:^(xdg-desktop-portal)$"
        "float, class:^(dropdown-term)$"

        # Pin and place the dropdown terminal
        "pin, class:^(dropdown-term)$"
        "workspace special:dropdown, class:^(dropdown-term)$"
        "size 100% 40%, class:^(dropdown-term)$"
        "move 0 0, class:^(dropdown-term)$"

        # Workspace pinning
        "workspace 2, class:^(firefox)$"
        "workspace 3, class:^(code|cursor)$"

        # Kitty terminal — slight transparency
        "opacity 0.95 0.90, class:^(kitty)$"
      ];
    };
  };

  # Declaratively write ~/.config/hypr/hyprland.conf keybindings/config.
  # Home Manager renders this from wayland.windowManager.hyprland.settings.
}
