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
    };

    outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, plasma-manager, ... }@inputs: {
        nixosConfigurations = {
            dell3510 = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";

                specialArgs = {
                    pkgs-unstable = import nixpkgs-unstable {
                        system = "x86_64-linux";
                        config.allowUnfree = true;
                    };
                };
                
                modules = [
                    home-manager.nixosModules.home-manager
                    ./common/default.nix
                    ./common/users.nix
                    ./modules/desktop.nix
                    ./modules/scolaire.nix
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
                    home-manager.nixosModules.home-manager
                    ./common/default.nix
                    ./common/users.nix
                    ./hosts/server/configuration.nix
                    ./hosts/server/services.nix
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
