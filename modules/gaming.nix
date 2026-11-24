{ config, lib, pkgs, ... }:

with lib;

{
  options.profilGaming = {
    enable = mkEnableOption "Active l'environnement gaming (Steam, pilotes 32 bits, MangoHud)";
  };

  config = mkIf config.profilGaming.enable {
    # Accélération matérielle graphique
    hardware.graphics = {
      enable = true;
      enable32Bit = true; # Compatibilité jeux 32 bits
    };

    programs.steam.enable = true;

    environment.systemPackages = with pkgs; [
      protonup-qt
      mangohud # Overlay FPS/Température
      melonds
    ];
  };
}
