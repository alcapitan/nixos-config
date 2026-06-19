{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Applications principales
    firefox
    thunderbird
    libreoffice-qt-fresh
    vlc
    brave
    vscode
    beeper
    proton-vpn
    discord
    proton-authenticator
    
    # Outils KDE / Utilitaires
    kdePackages.kate
    kdePackages.kcharselect
    kdePackages.kcolorchooser
    kdePackages.merkuro
    kdePackages.filelight
    kdePackages.kcalc
    kdePackages.plasma-browser-integration
    
    # Design / Multimédia
    inkscape
    gimp
    yt-dlp
    parabolic
    tagger
    
    # Outils Dev / Docs
    android-studio
    android-tools
    pdftk
    imagemagick
    _7zip-zstd
  ];

  # Configuration spécifique à Plasma (Fond d'écran...)
  programs.plasma = {
    enable = true;
    workspace = {
      wallpaper = "/home/alex/Pictures/wallpapers/pont du gard.jpg";
    };
    input.keyboard.numlockOnStartup = "off";
  };

  # Raccourci Web personnalisé
  xdg.desktopEntries = {
    open-gemini = {
      name = "Ouvrir Gemini";
      exec = "xdg-open https://gemini.google.com";
      icon = "internet-web-browser";
      settings = {
        X-KDE-Shortcuts = "Ctrl+Alt+G";
      };
    };
  };

  # Configuration du Terminal Konsole
  programs.konsole = {
    enable = true;
    defaultProfile = "MonProfil";
    profiles = {
      "MonProfil" = {
        name = "MonProfil";
        font = {
          name = "JetBrainsMono Nerd Font";
          size = 12;
        };
      };
    };
  };

  # Configuration de l'éditeur Kate
  programs.kate = {
    enable = true;
    editor.brackets.automaticallyAddClosing = false;
    editor.font = {
      family = "JetBrainsMono Nerd Font";
      pointSize = 12;
    };
  };
}