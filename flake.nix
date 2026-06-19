{
    description = "Configuration NixOS pour mon ordinateur perso";

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
    };

    outputs = { self, nixpkgs, home-manager, plasma-manager, ... }@inputs: {
        nixosConfigurations = {
            dell3510 = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./configuration.nix

                    home-manager.nixosModules.home-manager
                    {
                        home-manager.useGlobalPkgs = true;
                        home-manager.useUserPackages = true;

                        home-manager.sharedModules = [
                            plasma-manager.homeModules.plasma-manager
                        ];

                        home-manager.users.alex = {
                            imports = [
                                ./home.nix
                                # ./thunderbird.nix
                            ];
                        };
                    }
                ];
            };
        };
    };
}
