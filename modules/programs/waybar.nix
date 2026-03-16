{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [
          "cpu"
          "memory"
          "pulseaudio"
          "network"
          "battery"
          "tray"
        ];

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{icon}";
          format-icons = {
            default = "";
            active = "";
            urgent = "";
          };
        };

        clock = {
          format = " {:%H:%M}";
          tooltip-format = "{:%A, %d %B %Y}";
        };

        cpu = {
          format = " {usage}%";
          tooltip = true;
        };

        memory = {
          format = " {used:0.1f}G";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰝟 muted";
          format-icons = {
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
        };

        network = {
          format-wifi = " {signalStrength}%";
          format-ethernet = "󰈀 wired";
          format-disconnected = "󰖪 offline";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-icons = [
            "󰁺" "󰁻" "󰁼" "󰁽" "󰁾"
            "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"
          ];
        };

        tray = {
          spacing = 8;
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 10px;
        font-family: JetBrainsMono Nerd Font, monospace;
        font-size: 12px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(20, 20, 20, 0.85);
        color: #e5e5e5;
      }

      #workspaces button {
        padding: 0 8px;
        color: #777;
      }

      #workspaces button.active {
        color: #ffffff;
        background: rgba(255, 255, 255, 0.15);
      }

      #workspaces button.urgent {
        color: #ff5555;
      }

      #clock,
      #cpu,
      #memory,
      #pulseaudio,
      #network,
      #battery,
      #tray {
        padding: 0 10px;
        margin: 4px 4px;
        background: rgba(255, 255, 255, 0.08);
      }

      #battery.warning { color: #f1fa8c; }
      #battery.critical { color: #ff5555; }

      tooltip {
        background: #1e1e2e;
        border-radius: 8px;
        padding: 8px;
      }
    '';
  };
}

