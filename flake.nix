{
    description = "Al Capitan's NixOS configurations repository";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
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

    outputs = { self, nixpkgs, sops-nix, home-manager, plasma-manager, ... }@inputs:
        let
            system = "x86_64-linux";
            pkgs = nixpkgs.legacyPackages.${system};
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
                    system = "x86_64-linux";

                    modules = [
                        sops-nix.nixosModules.sops
                        home-manager.nixosModules.home-manager
                        ./common/default.nix
                        ./common/users.nix
                        ./modules/desktop.nix
                        ./modules/scolaire.nix
                        ./modules/gaming.nix
                        ./hosts/laptop/configuration.nix
                        {
                            home-manager.useGlobalPkgs = true;
                            home-manager.useUserPackages = true;
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
                        ./common/users.nix
                        ./hosts/server/configuration.nix
                        {
                            home-manager.useGlobalPkgs = true;
                            home-manager.useUserPackages = true;
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
