##############################################################################
# home/desktop/waybar.nix  [Home Manager module]
#
# Waybar — top status bar, Catppuccin Mocha themed.
# Modules: workspaces, window title, clock, CPU, memory, network,
#          audio (PipeWire/PulseAudio), battery, system tray.
##############################################################################
{ ... }:

let
  # Catppuccin Mocha
  base     = "#1e1e2e";
  mantle   = "#181825";
  crust    = "#11111b";
  surface0 = "#313244";
  surface1 = "#45475a";
  overlay0 = "#6c7086";
  text     = "#cdd6f4";
  subtext1 = "#bac2de";
  mauve    = "#cba6f7";
  blue     = "#89b4fa";
  sapphire = "#74c7ec";
  sky      = "#89dceb";
  teal     = "#94e2d5";
  green    = "#a6e3a1";
  yellow   = "#f9e2af";
  peach    = "#fab387";
  maroon   = "#eba0ac";
  red      = "#f38ba8";
  pink     = "#f5c2e7";
in
{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer    = "top";
        position = "top";
        height   = 34;
        spacing  = 4;

        modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right  = [
          "cpu" "memory" "temperature"
          "pulseaudio" "network"
          "battery" "tray"
        ];

        # ── Workspaces ──────────────────────────────────────────────────
        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs    = true;
          format         = "{icon}";
          format-icons   = {
            "1"     = "󰎤";
            "2"     = "󰎧";
            "3"     = "󰎪";
            "4"     = "󰎭";
            "5"     = "󰎱";
            "6"     = "󰎳";
            "7"     = "󰎶";
            "8"     = "󰎹";
            "9"     = "󰎼";
            "10"    = "󰎿";
            default = "󰊠";
            active  = "󰮯";
            urgent  = "󰀨";
          };
          persistent-workspaces = {
            "*" = 5;
          };
        };

        # ── Window title ────────────────────────────────────────────────
        "hyprland/window" = {
          max-length  = 60;
          format      = "  {}";
          rewrite     = {
            "(.*) — Mozilla Firefox" = " $1";
            "(.*) - nvim"            = " $1";
          };
          separate-outputs = true;
        };

        # ── Clock ────────────────────────────────────────────────────────
        clock = {
          format         = "  {:%H:%M}";
          format-alt     = "  {:%A, %d %B %Y}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          calendar = {
            mode           = "year";
            mode-mon-col   = 3;
            on-scroll      = 1;
            on-click-right = "mode";
            format = {
              months    = "<span color='${blue}'><b>{}</b></span>";
              days      = "<span color='${text}'>{}</span>";
              weeks     = "<span color='${mauve}'><b>W{}</b></span>";
              weekdays  = "<span color='${sapphire}'><b>{}</b></span>";
              today     = "<span color='${green}'><b><u>{}</u></b></span>";
            };
          };
        };

        # ── CPU ──────────────────────────────────────────────────────────
        cpu = {
          format    = " {usage}%";
          tooltip   = true;
          interval  = 2;
          on-click  = "kitty --title 'System Monitor' btm";
        };

        # ── Memory ───────────────────────────────────────────────────────
        memory = {
          format   = " {used:0.1f}G";
          interval = 4;
          tooltip-format = "RAM: {used:0.1f} / {total:0.1f} GiB\nSwap: {swapUsed:0.1f} / {swapTotal:0.1f} GiB";
        };

        # ── Temperature ──────────────────────────────────────────────────
        temperature = {
          thermal-zone     = 2;
          critical-threshold = 80;
          format           = " {temperatureC}°C";
          format-critical  = " {temperatureC}°C";
        };

        # ── Audio (PipeWire / PulseAudio) ─────────────────────────────────
        pulseaudio = {
          format          = "{icon} {volume}%";
          format-muted    = "󰝟 muted";
          format-icons    = {
            headphone       = "";
            hands-free      = "󰤝";
            headset         = "󰤴";
            phone           = "";
            portable        = "";
            car             = "";
            default         = [ "󰕿" "󰖀" "󰕾" ];
          };
          on-click         = "pavucontrol";
          on-click-right   = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          scroll-step      = 2.0;
          tooltip          = true;
          tooltip-format   = "{icon} {volume}%  {desc}";
        };

        # ── Network ───────────────────────────────────────────────────────
        network = {
          format-wifi        = "  {signalStrength}%";
          format-ethernet    = "󰈀 wired";
          format-disconnected = "󰖪 offline";
          format-linked      = "󰈁 {ifname} (no ip)";
          tooltip-format-wifi = "{essid} ({signalStrength}%)\n󰛴  {bandwidthUpBytes}   {bandwidthDownBytes}";
          tooltip-format-ethernet = "{ifname}\n󰛴  {bandwidthUpBytes}   {bandwidthDownBytes}";
          on-click           = "nm-connection-editor";
          interval           = 5;
        };

        # ── Battery ───────────────────────────────────────────────────────
        battery = {
          states = {
            warning  = 30;
            critical = 15;
          };
          format          = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged  = "󰚥 {capacity}%";
          format-icons    = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          tooltip-format  = "{timeTo}\nCycle count: {cycles}";
        };

        # ── System tray ───────────────────────────────────────────────────
        tray = {
          spacing = 10;
          icon-size = 16;
        };
      };
    };

    # ── CSS: Catppuccin Mocha ────────────────────────────────────────────────
    style = ''
      /* ────── Reset ────────────────────────────────────────── */
      * {
        border:        none;
        border-radius: 0;
        font-family:   "JetBrainsMono Nerd Font", monospace;
        font-size:     13px;
        min-height:    0;
      }

      /* ────── Bar window ───────────────────────────────────── */
      window#waybar {
        background: rgba(30, 30, 46, 0.88); /* base + alpha */
        color:      ${text};
        border-bottom: 1px solid ${surface0};
      }

      /* ────── Module base ──────────────────────────────────── */
      .modules-left,
      .modules-center,
      .modules-right {
        margin: 3px 6px;
      }

      #workspaces,
      #window,
      #clock,
      #cpu,
      #memory,
      #temperature,
      #pulseaudio,
      #network,
      #battery,
      #tray {
        padding:          4px 12px;
        margin:           2px 3px;
        border-radius:    10px;
        background-color: ${surface0};
        color:            ${text};
        transition:       all 0.2s ease;
      }

      /* ────── Workspaces ───────────────────────────────────── */
      #workspaces {
        background: transparent;
        padding:    0 4px;
      }

      #workspaces button {
        padding:          2px 8px;
        border-radius:    8px;
        color:            ${overlay0};
        background:       transparent;
        transition:       all 0.15s ease;
      }

      #workspaces button:hover {
        background: ${surface1};
        color:      ${text};
      }

      #workspaces button.active {
        background: ${mauve};
        color:      ${base};
        font-weight: bold;
      }

      #workspaces button.urgent {
        background: ${red};
        color:      ${base};
      }

      /* ────── Window title ─────────────────────────────────── */
      #window {
        color:      ${subtext1};
        font-style: italic;
      }

      /* ────── Clock ────────────────────────────────────────── */
      #clock {
        color:       ${sky};
        font-weight: bold;
      }

      /* ────── CPU ──────────────────────────────────────────── */
      #cpu {
        color: ${blue};
      }

      /* ────── Memory ───────────────────────────────────────── */
      #memory {
        color: ${mauve};
      }

      /* ────── Temperature ──────────────────────────────────── */
      #temperature {
        color: ${yellow};
      }

      #temperature.critical {
        background: ${red};
        color:      ${base};
      }

      /* ────── Audio ────────────────────────────────────────── */
      #pulseaudio {
        color: ${teal};
      }

      #pulseaudio.muted {
        color: ${overlay0};
      }

      /* ────── Network ──────────────────────────────────────── */
      #network {
        color: ${green};
      }

      #network.disconnected {
        color: ${red};
      }

      /* ────── Battery ──────────────────────────────────────── */
      #battery {
        color: ${sapphire};
      }

      #battery.warning {
        color: ${yellow};
      }

      #battery.critical {
        color:      ${red};
        animation:  blink 1s step-start infinite;
      }

      #battery.charging,
      #battery.plugged {
        color: ${green};
      }

      @keyframes blink {
        to { opacity: 0; }
      }

      /* ────── Tooltip ──────────────────────────────────────── */
      tooltip {
        background:    ${mantle};
        border:        1px solid ${mauve};
        border-radius: 8px;
        color:         ${text};
      }
    '';
  };
}
