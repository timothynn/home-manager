##############################################################################
# home/theme/catppuccin.nix  [Home Manager module]
#
# Global catppuccin-nix defaults.
# Sets the flavour + accent once; individual programs opt-in with
#   programs.<name>.catppuccin.enable = true;
# in their own module files.
##############################################################################
{ ... }:

{
  catppuccin = {
    flavor = "mocha";
    accent = "mauve";
  };
}
