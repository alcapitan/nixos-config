{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, lanzaboote, sops-nix, home-manager, plasma-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "ventoy-qt5-1.1.18"
        ];
      };
    };

    mkHost = { hostName, extraModules ? [ ], homeModules ? [ ] }:
      nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit pkgs-unstable inputs;
        };

        modules = [
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          ./common
          ./modules/borg.nix
          ./hosts/${hostName}/configuration.nix
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = {
              inherit pkgs-unstable inputs;
            };
            home-manager.users.alex = {
              imports = [
                ./home
              ] ++ homeModules;
            };
          }
        ] ++ extraModules;
      };
  in
  {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        sops
        age
        ssh-to-age
      ];
    };

    nixosConfigurations = {
      laptop = mkHost {
        hostName = "laptop";
        extraModules = [
          lanzaboote.nixosModules.lanzaboote
          ./modules/dns.nix
          ./modules/desktop.nix
        ];
        homeModules = [
          plasma-manager.homeModules.plasma-manager
          ./home/desktop
        ];
      };

      server = mkHost {
        hostName = "server";
      };
    };
  };
}
