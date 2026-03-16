{ lib, pkgs, ... }:

let
  hasSopsFile = builtins.pathExists ../../secrets/secrets.yaml;
in
{
  environment.systemPackages = with pkgs; [ sops age ssh-to-age ];

  sops = lib.mkIf hasSopsFile {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age = {
      # Create once with:
      #   age-keygen -o ~/.config/sops/age/keys.txt
      keyFile = "/home/tim/.config/sops/age/keys.txt";
      generateKey = false;
    };

    # Example secret expected in secrets.yaml:
    # githubToken: ENC[AES256_GCM,...]
    secrets.githubToken = {
      owner = "tim";
      mode = "0400";
    };
  };
}
