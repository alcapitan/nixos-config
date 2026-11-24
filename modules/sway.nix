{ config, lib, pkgs, ... }:

with lib;

{
  options.profilSway = {
    enable = mkEnableOption "Active le compositeur Wayland minimaliste Sway en session alternative";
  };

  config = mkIf config.profilSway.enable {
    # Active Sway et configure les wrappers GTK / Portals
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    # Utilitaires essentiels pour un setup Wayland minimaliste
    environment.systemPackages = with pkgs; [
      foot         # Terminal Wayland rapide et sobre (par défaut sur Sway)
      wofi         # Lanceur d'applications léger
      waybar       # Barre de statut configurable
      mako         # Démon de notification léger
      wl-clipboard # Gestion du presse-papiers sous Wayland
      grim         # Capture d'écran (outil CLI)
      slurp        # Sélection de zone pour les captures
    ];
  };
}
