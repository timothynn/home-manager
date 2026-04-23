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
        # .NET 6 is EOL upstream (Nov 2024) so nixpkgs keeps it behind the
        # insecure gate. The SDK attr is `sdk_6_0_4xx` (v6.0.428) — add
        # further pins here if you re-enable older SDKs (7/etc).
        permittedInsecurePackages = [
          "dotnet-sdk-6.0.428"
          "dotnet-sdk-wrapped-6.0.428"
          "dotnet-runtime-6.0.36"
          "aspnetcore-runtime-6.0.36"
        ];
      };
    };
    # .NET 6 only for now. Additional SDKs (7/8/9/10) stay commented —
    # uncomment the matching line AND the corresponding entry in
    # `dotnetSdkList` in home.nix to pull them in.
    dotnetSdks = builtins.concatLists [
      (lib.optionals (pkgs.dotnetCorePackages ? sdk_6_0_4xx) [ pkgs.dotnetCorePackages.sdk_6_0_4xx ])
      # (lib.optionals (pkgs.dotnetCorePackages ? sdk_8_0)     [ pkgs.dotnetCorePackages.sdk_8_0     ])
      # (lib.optionals (pkgs.dotnetCorePackages ? sdk_10_0)    [ pkgs.dotnetCorePackages.sdk_10_0    ])
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

      # .NET 6 devShell. Add more SDKs via the `dotnetSdks` let-binding
      # and the `permittedInsecurePackages` pins at the top of this file.
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
