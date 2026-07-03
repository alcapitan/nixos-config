{ pkgs, ... }:

{
  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "25.11";

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Configuration du Shell commun
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  # Prompt moderne commun
  programs.starship = {
    enable = true;
    settings = {};
  };

  # Configuration de Git
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Al Capitan";
        email = "alexandre.boyer29@gmail.com"; 
      };
    };
  };

  # Accès SSH commun vers le stockage Borg
  programs.ssh = {
    enable = true; 
    enableDefaultConfig = false;
    
    settings = {
      "Host borg-repo" = {
        HostName = "u502181-sub4.your-storagebox.de";
        User = "u502181-sub4";
        Port = "23";
      };
      "Host alcap" = {
        HostName = "alcapitan.me";
        User = "alex";
        Port = "1274";
      };
    };
  };

  home.shellAliases = {
    nix-switch = "sudo nixos-rebuild switch --flake /home/alex/nixos-config#dell3510";
    nix-test   = "sudo nixos-rebuild test --flake /home/alex/nixos-config#dell3510";
    nix-dry    = "sudo nixos-rebuild dry-activate --flake /home/alex/nixos-config#dell3510";
    nix-boot   = "sudo nixos-rebuild boot --flake /home/alex/nixos-config#dell3510";
    nix-update = "nix flake update --flake /home/alex/nixos-config && sudo nixos-rebuild switch --flake /home/alex/nixos-config#dell3510";
  };
}