##############################################################################
# modules/programs/wofi.nix  [Home Manager module]
#
# Wofi — Wayland-native application launcher.
# Catppuccin Mocha styled with rounded corners and a clean minimal layout.
##############################################################################
{ ... }:

{
  programs.wofi = {
    enable = true;

    settings = {
      width            = 620;
      height           = 420;
      location         = "center";
      show             = "drun";
      prompt           = "  Search…";
      filter_rate      = 100;
      allow_markup     = true;
      no_actions       = true;
      halign           = "fill";
      orientation      = "vertical";
      content_halign   = "fill";
      insensitive      = true;
      allow_images     = true;
      image_size       = 40;
      gtk_dark         = true;
      dynamic_lines    = true;
    };

    style = ''
      /* ─── Catppuccin Mocha ────────────────────────────────────────────── */
      * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 14px;
      }

      window {
        margin:           0;
        padding:          0;
        border:           2px solid #cba6f7;
        border-radius:    14px;
        background-color: #1e1e2e;
        color:            #cdd6f4;
      }

      #input {
        margin:           10px 10px 4px;
        padding:          10px 14px;
        border:           none;
        border-bottom:    2px solid #45475a;
        border-radius:    8px;
        background-color: #181825;
        color:            #cdd6f4;
        outline:          none;
      }

      #input:focus {
        border-bottom-color: #cba6f7;
      }

      #inner-box {
        margin: 4px 10px 10px;
      }

      #outer-box {
        margin: 0;
        border: none;
      }

      #scroll {
        margin-top: 4px;
      }

      #text {
        padding:    4px 8px;
        color:      #cdd6f4;
      }

      #entry {
        padding:       6px 4px;
        border-radius: 8px;
      }

      #entry:selected {
        background-color: #313244;
      }

      #entry:selected #text {
        color: #cba6f7;
      }

      #image {
        margin-right: 10px;
      }
    '';
  };
}
