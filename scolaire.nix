{  config, lib, pkgs, ... }:

with lib;

{
    options.profilScolaire = {
        enable = mkEnableOption "Active l'environnement scolaire";
    };

    config = mkIf config.profilScolaire.enable {
        environment.systemPackages = with pkgs; [
            gcc
            gnumake
            jetbrains.idea
            eclipses.eclipse-java
            miktex
        ];
    };
}
