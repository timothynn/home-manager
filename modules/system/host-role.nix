{ lib, pkgs, hostRole ? "auto", ... }:

let
  resolvedRole =
    if hostRole == "laptop" then "laptop"
    else if hostRole == "desktop" then "desktop"
    else "laptop";
in
{
  # Profile behavior: explicit laptop/desktop roles or "auto" fallback to laptop.
  # Hardware auto-detection is provided by flake app `auto-switch` at runtime.
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = builtins.elem resolvedRole [ "laptop" "desktop" ];
          message = "resolvedRole must be laptop or desktop.";
        }
      ];
    }

    (lib.mkIf (resolvedRole == "laptop") {
      services.tlp.enable = true;
      services.power-profiles-daemon.enable = false;
      powerManagement.powertop.enable = true;
      services.thermald.enable = true;
      services.upower.enable = true;
      hardware.sensor.iio.enable = true;
    })

    (lib.mkIf (resolvedRole == "desktop") {
      services.tlp.enable = false;
      services.power-profiles-daemon.enable = true;
      powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
      services.thermald.enable = true;
      services.upower.enable = true;
    })
  ];
}
