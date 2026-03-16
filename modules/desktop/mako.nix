##############################################################################
# modules/desktop/mako.nix  [Home Manager module]
#
# Mako — lightweight Wayland notification daemon.
# Styled with Catppuccin Mocha colours and rounded corners.
# Imported from home.nix, NOT from configuration.nix.
##############################################################################
{ ... }:

{
  services.mako = {
    enable = true;

    settings = {
      # Catppuccin Mocha
      background-color = "#1e1e2e";
      text-color       = "#cdd6f4";
      border-color     = "#cba6f7"; # mauve
      progress-color   = "#a6e3a1"; # green

      border-radius = 8;
      border-size   = 2;

      padding   = "12,16";
      margin    = "8";
      width     = 360;
      height    = 120;

      font = "JetBrainsMono Nerd Font 11";
    };

    # Urgency overrides
    extraConfig = ''
      [urgency=low]
      border-color=#89b4fa

      [urgency=high]
      border-color=#f38ba8
      background-color=#181825
    '';
  };
}
