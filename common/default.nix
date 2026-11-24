{ pkgs, ... }:

{
  imports = [
    ./users.nix
    ./scripts.nix
  ];

  # Fonctionnalités expérimentales (Flakes)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.channel.enable = false;
  nix.settings.auto-optimise-store = true;

  # Localisation
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";
  console.keyMap = "fr";

  # Sécurité et Shell de base
  security.sudo.extraConfig = ''
    Defaults env_reset,pwfeedback
  '';

  # Rotation et nettoyage des journaux
  services.journald.extraConfig = ''
    SystemMaxUse=1G
    SystemMaxFileSize=100M
    MaxRetentionSec=1month
  '';

  programs.zsh = {
    enable = true;
    interactiveShellInit = ''
      eval "$(direnv hook zsh)"
    '';
  };

  nixpkgs.config.allowUnfree = true;
  programs.nix-ld.enable = true;

  # Paquets système disponibles partout (même sur le serveur)
  environment.systemPackages = with pkgs; [
    tree
    git
    curl
    fastfetch
    librespeed-cli
    gnupg
    _7zip-zstd
    vulnix

    # nouveaux outils modernisés
    btop # remplace top/htop
    fd # remplace find
    ripgrep # appeler rg, remplace grep
    sd # remplacer sed, donc remplace du texte
    bat # remplace cat
    eza # remplace ls
    zoxide # appeler z, remplace cd ; zoxide query --list --score
    duf # remplace df, donc affiche l'état des points de montage
    dust # remplace du, donc affiche le poids des fichiers
    delta # remplace diff
    procs # remplace ps
    tealdeer # remplace man, donc des tutos d'utilisation pour plein de commandes
    gping # remplace ping
    hyperfine # remplace time, donc pour des benchmarks
    nh # remplace nixos-rebuild
    nix-output-monitor # pour l'arbre de reconstruction de nh
    jq # parser de json
    glow # lecteur markdown
  ];

  systemd.tmpfiles.rules = [
    "L+ /home/alex/nixos-config - - - - /etc/nixos"
  ];
}
