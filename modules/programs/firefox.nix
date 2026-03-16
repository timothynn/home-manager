##############################################################################
# modules/programs/firefox.nix  [Home Manager module]
#
# Firefox with sensible privacy/UX defaults and Catppuccin Mocha colours
# applied via userChrome.css overrides.
##############################################################################
{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;

    profiles.default = {
      name      = "Default";
      id        = 0;
      isDefault = true;

      settings = {
        # Enable userChrome / userContent customisation
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # Performance
        "gfx.webrender.all"                     = true;
        "media.ffmpeg.vaapi.enabled"             = true;

        # Privacy
        "privacy.trackingprotection.enabled"     = true;
        "geo.enabled"                            = false;
        "browser.send_pings"                     = false;
        "dom.battery.enabled"                    = false;

        # UX — disable annoying defaults
        "browser.toolbars.bookmarks.visibility"  = "never";
        "browser.startup.page"                   = 3; # restore previous session
        "browser.download.useDownloadDir"        = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      };

      # Catppuccin Mocha userChrome overrides
      userChrome = ''
        /* Catppuccin Mocha – compact toolbar */
        :root {
          --ctp-base:     #1e1e2e;
          --ctp-mantle:   #181825;
          --ctp-crust:    #11111b;
          --ctp-surface0: #313244;
          --ctp-surface1: #45475a;
          --ctp-text:     #cdd6f4;
          --ctp-mauve:    #cba6f7;
          --ctp-blue:     #89b4fa;
          --ctp-green:    #a6e3a1;
          --ctp-red:      #f38ba8;
        }

        #navigator-toolbox {
          background-color: var(--ctp-mantle) !important;
          border-bottom: 1px solid var(--ctp-surface0) !important;
        }

        #nav-bar {
          background-color: var(--ctp-mantle) !important;
        }

        .tab-background[selected] {
          background-color: var(--ctp-surface0) !important;
        }

        .tab-label {
          color: var(--ctp-text) !important;
        }

        #urlbar-background {
          background-color: var(--ctp-surface0) !important;
          border: 1px solid var(--ctp-mauve) !important;
          border-radius: 8px !important;
        }

        #urlbar .urlbar-input {
          color: var(--ctp-text) !important;
        }
      '';
    };
  };
}
