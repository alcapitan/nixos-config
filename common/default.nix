{ pkgs, ... }:

{
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
  
  programs.zsh = {
    enable = true;
    interactiveShellInit = ''
      eval "$(direnv hook zsh)"
    '';
  };

  nixpkgs.config.allowUnfree = true;

  # Paquets système disponibles partout (même sur le VPS)
  environment.systemPackages = with pkgs; [
    tree
    git
    curl
    fastfetch
    btop
    gnupg
    _7zip-zstd
  ];
}