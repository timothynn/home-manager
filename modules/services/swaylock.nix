{ pkgs, ... }:

{
  programs.swaylock = {
    enable = true;

    # Optional settings
    settings = {
      # Background color
      background = "0x1e1e2e";       # dark gray/purple

      # Show indicator when typing password
      indicator = true;

      # Show caps lock status
      showCapsLock = true;

      # Screen blur (requires wlroots >= 0.14)
      blur = 5;
      # Adjust text/prompt color
      textColor = "0xffffffff";
      ringColor = "0xfff5a97f";
      ringVerColor = "0xffa3be8c";     # verified ring
      ringWrongColor = "0xffbf616a";   # wrong password
    };
  };
}

