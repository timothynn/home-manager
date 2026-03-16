##############################################################################
# modules/system/locale.nix
#
# Timezone, locale, and keyboard layout.
# Adjust timeZone and xkb.layout to match your region.
##############################################################################
{ ... }:

{
  time.timeZone = "Africa/Nairobi"; # change to your TZ (e.g. "America/New_York")

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS        = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT    = "en_US.UTF-8";
      LC_MONETARY       = "en_US.UTF-8";
      LC_NAME           = "en_US.UTF-8";
      LC_NUMERIC        = "en_US.UTF-8";
      LC_PAPER          = "en_US.UTF-8";
      LC_TELEPHONE      = "en_US.UTF-8";
      LC_TIME           = "en_US.UTF-8";
    };
  };

  # Virtual console keymap
  console.keyMap = "us";

  # X11 / Wayland keyboard layout (picks up in Hyprland too)
  services.xserver.xkb = {
    layout  = "us";
    variant = "";
  };
}
