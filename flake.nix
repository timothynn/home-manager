{
  description = "Catppuccin NixOS superflake (auto laptop/desktop + dev + secrets)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland from its own flake, pinned to a tagged release so that
    # `nix flake update` doesn't silently drag in breaking syntax changes
    # (this was #1's whole story). Bump the ref when you deliberately want
    # a newer version; otherwise leave it here.
    hyprland = {
      url = "github:hyprwm/Hyprland?ref=v0.54.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Catppuccin declarative theming
    catppuccin.url = "github:catppuccin/nix";

    # Secrets management (SOPS + age)
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, catppuccin, sops-nix, ... } @ inputs:
  let
    system   = "x86_64-linux";
    username = "tim";
    lib = nixpkgs.lib;

    mkSystem = hostRole: hostName:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username hostRole hostName; };
        modules = [
          ./hosts/default/configuration.nix
          catppuccin.nixosModules.catppuccin
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            networking.hostName = hostName;

            home-manager = {
              useGlobalPkgs    = true;
              useUserPackages  = true;
              backupFileExtension = "hm-backup";
              extraSpecialArgs = { inherit inputs username hostRole hostName; };
              users.${username} = import ./home.nix;
              sharedModules    = [ catppuccin.homeModules.catppuccin ];
            };
          }
        ];
      };

    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "dotnet-sdk-6.0.428"
          "dotnet-sdk-7.0.410"
        ];
      };
    };
    dotnetSdks = builtins.concatLists [
      (lib.optionals (pkgs ? dotnet-sdk_6) [ pkgs.dotnet-sdk_6 ])
      (lib.optionals (pkgs ? dotnet-sdk_7) [ pkgs.dotnet-sdk_7 ])
      (lib.optionals (pkgs ? dotnet-sdk_8) [ pkgs.dotnet-sdk_8 ])
      (lib.optionals (pkgs ? dotnet-sdk_9) [ pkgs.dotnet-sdk_9 ])
      (lib.optionals (pkgs ? dotnet-sdk_10) [ pkgs.dotnet-sdk_10 ])
    ];
  in
  {
    nixosConfigurations = {
      # Auto profile selection at eval time using DMI chassis type.
      default = mkSystem "auto" "nixos";

      # Explicit targets.
      laptop  = mkSystem "laptop" "nixos-laptop";
      desktop = mkSystem "desktop" "nixos-desktop";
    };

    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit inputs username; };
      modules = [
        ./home.nix
        catppuccin.homeModules.catppuccin
      ];
    };

    devShells.${system} = {
      rust = pkgs.mkShell {
        packages = with pkgs; [
          rustc cargo rust-analyzer clippy rustfmt
          pkg-config openssl
        ];
        shellHook = ''
          export RUST_BACKTRACE=1
        '';
      };

      python = pkgs.mkShell {
        packages = with pkgs; [
          python312
          python312Packages.pip
          python312Packages.virtualenv
          python312Packages.ipython
          pyright
          ruff
          uv
        ];
      };

      node = pkgs.mkShell {
        packages = with pkgs; [
          nodejs_24
          pnpm
          yarn
          typescript
          typescript-language-server
          eslint
          prettierd
        ];
      };

      dotnet = pkgs.mkShell {
        packages = dotnetSdks ++ (with pkgs; [
          dotnet-ef
          nuget
          powershell
        ]);
        shellHook = ''
          export DOTNET_CLI_TELEMETRY_OPTOUT=1
          export DOTNET_NOLOGO=1
        '';
      };
    };

    apps.${system}.auto-switch = {
      type = "app";
      program = lib.getExe (pkgs.writeShellApplication {
        name = "superflake-auto-switch";
        runtimeInputs = with pkgs; [ coreutils gnugrep ];
        text = ''
          set -euo pipefail

          chassis=""
          if [ -r /sys/class/dmi/id/chassis_type ]; then
            chassis="$(tr -d '[:space:]' < /sys/class/dmi/id/chassis_type)"
          fi

          target="desktop"
          case "$chassis" in
            8|9|10|14) target="laptop" ;;
          esac

          exec sudo nixos-rebuild switch --flake ${self}#"$target"
        '';
      });
    };
  };
}
