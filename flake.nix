{
    description = "Al Capitan's NixOS configurations repository";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
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

    outputs = { self, nixpkgs, nixpkgs-unstable, sops-nix, home-manager, plasma-manager, ... }@inputs:
        let
            system = "x86_64-linux";
            pkgs = nixpkgs.legacyPackages.${system};
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
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
                dell3510 = nixpkgs.lib.nixosSystem {
                    inherit system;

                    specialArgs = {
                      inherit pkgs-unstable;
                    };

                    modules = [
                        sops-nix.nixosModules.sops
                        home-manager.nixosModules.home-manager
                        ./common/default.nix
                        ./modules/dns.nix
                        ./modules/desktop.nix
                        ./hosts/laptop/configuration.nix
                        {
                            home-manager.useGlobalPkgs = true;
                            home-manager.useUserPackages = true;
                            home-manager.backupFileExtension = "backup";
                            home-manager.extraSpecialArgs = {
                              inherit pkgs-unstable;
                            };
                            home-manager.users.alex = {
                                imports = [
                                    plasma-manager.homeModules.plasma-manager
                                    ./home/default.nix
                                    ./home/desktop.nix
                                ];
                            };
                        }
                    ];
                };

                vps = nixpkgs.lib.nixosSystem {
                    system = "x86_64-linux";
                    modules = [
                        sops-nix.nixosModules.sops
                        home-manager.nixosModules.home-manager
                        ./common/default.nix
                        ./hosts/server/configuration.nix
                        {
                            home-manager.useGlobalPkgs = true;
                            home-manager.useUserPackages = true;
                            home-manager.backupFileExtension = "backup";
                            home-manager.users.alex = {
                                imports = [
                                    ./home/default.nix
                                ];
                            };
                        }
                    ];
                };
            };
        };
}
