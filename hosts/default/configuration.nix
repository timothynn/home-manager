##############################################################################
# hosts/default/configuration.nix
#
# Top-level NixOS system configuration for the "default" host.
# Imports all system-level modules and wires up the user account.
# Home Manager user config lives in home.nix (via flake.nix).
##############################################################################
{ config, pkgs, inputs, username, hostRole ? "auto", ... }:

{
  imports = [
    ./hardware-configuration.nix

    # Core system behaviour
    ../../modules/system/default.nix
    ../../modules/system/fonts.nix
    ../../modules/system/locale.nix
    ../../modules/system/networking.nix
    ../../modules/system/host-role.nix
    ../../modules/system/secrets.nix

    # Services
    ../../modules/services/seabury-vpn.nix

    # Desktop stack (system-layer: service enablement, env vars, SDDM)
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/sddm.nix
  ];

  # ---------------------------------------------------------------------------
  # User account
  # ---------------------------------------------------------------------------
  users.users.${username} = {
    isNormalUser = true;
    description  = username;
    extraGroups  = [ "wheel" "networkmanager" "audio" "video" "input" "storage" ];
    shell        = pkgs.zsh;
  };

  # sudo requires a password for wheel members
  security.sudo.wheelNeedsPassword = true;

  # Allow changing shell to nushell while keeping zsh as login default.
  environment.shells = [ pkgs.zsh pkgs.nushell ];

  # ---------------------------------------------------------------------------
  # Nix daemon & store settings
  # ---------------------------------------------------------------------------
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store   = true;
      trusted-users         = [ "root" "@wheel" ];

      # Binary caches: upstream Nix + Hyprland's own Cachix so we don't
      # rebuild Hyprland from source on every flake input bump.
      substituters = [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 7d";
    };
    # Dedup store paths on a weekly schedule (independent of
    # `auto-optimise-store`, which only runs at build time).
    optimise = {
      automatic = true;
      dates     = [ "weekly" ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    # .NET is disabled for now. Re-enable these pins if you reinstate
    # dotnet in home.nix / flake.nix.
    # permittedInsecurePackages = [
    #   "dotnet-sdk-6.0.428"
    #   "dotnet-sdk-7.0.410"
    # ];
  };

  system.stateVersion = "25.05";
}
