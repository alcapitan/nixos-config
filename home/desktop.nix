{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Applications principales
    brave #! deprecated
    firefox #! deprecated
    # librewolf
    thunderbird
    libreoffice-qt-fresh
    vlc
    vscode #! deprecated
    # vscodium
    beeper
    discord
    proton-authenticator
    
    # Outils KDE / Utilitaires
    kdePackages.kate
    kdePackages.kcharselect
    kdePackages.kcolorchooser
    kdePackages.filelight
    kdePackages.kcalc
    kdePackages.plasma-browser-integration
    kdePackages.kdepim-runtime
    kdePackages.kdepim-addons
    kdePackages.merkuro
    
    # Design / Multimédia
    inkscape
    gimp
    parabolic
    tagger
    
    # Outils Dev / Docs
    android-studio
    pdftk
    imagemagick
  
    # Self-made commands
    (pkgs.writeShellScriptBin "ytm-download" ''
      if [ -z "$1" ]; then
        echo "Usage: ytm-download <URL_OU_FICHIER.txt>"
        exit 1
      fi

      # Si l'argument est un fichier texte existant
      if [ -f "$1" ]; then
        echo "Téléchargement à partir du fichier texte : $1"
        
        ${pkgs.yt-dlp}/bin/yt-dlp \
          --batch-file "$1" \
          --default-search "ytsearch1" \
          -f "ba[ext=webm]/ba" \
          --extract-audio \
          --audio-format opus \
          -o "%(artist,uploader)s - %(title)s.%(ext)s" \
          --add-metadata \
          --embed-thumbnail \
          --ppa "ThumbnailsConvertor:-vf crop='ih:ih'" \
          --ignore-errors
      else
        # Si c'est une URL directe (playlist ou vidéo)
        ${pkgs.yt-dlp}/bin/yt-dlp \
          -f "ba[ext=webm]/ba" \
          --extract-audio \
          --audio-format opus \
          -o "%(artist,uploader)s - %(title)s.%(ext)s" \
          --add-metadata \
          --embed-thumbnail \
          --ppa "ThumbnailsConvertor:-vf crop='ih:ih'" \
          --ignore-errors \
          "$1"
      fi
    '')
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

  programs.librewolf = {
    enable = true;

    languagePacks = [ "fr" ];

    policies = {
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "78272b6fa58f4a1abaac99321d503a20@proton.me" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/proton-pass/latest.xpi";
          installation_mode = "force_installed";
        };
        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };

    settings = {
      "identity.fxaccounts.enabled" = true;
      "intl.locale.requested" = "fr,fr-FR";
      "intl.accept_languages" = "fr-fr,fr,en-us,en";

      "privacy.resistFingerprinting" = false;
      "layers.acceleration.force-enabled" = true;
      "gfx.webrender.all" = true;

      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "privacy.clearOnShutdown.sessions" = false;
      "privacy.sanitize.sanitizeOnShutdown" = false;
      "network.cookie.lifetimePolicy" = 0;
      "privacy.antiTracking.system.profile" = false; # pour conserver les connexions entre sessions

      "cookiebanners.service.mode" = 1; # rejette automatiquement les cookies
      "cookiebanners.service.mode.privateBrowsing" = 1; # rejette également en navigation privée
      "cookiebanners.bannerClicking.enabled" = true;

      "security.webauthn.webauthn_enable_softtoken" = true; # permet extensions pour passkeys
    };
  };

  /* # TODO
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "audio/mp4" = [ "vlc.desktop" ];
      "audio/ogg" = [ "vlc.desktop" ];
      "audio/x-mp3" = [ "vlc.desktop" ];
      "application/json" = [ "org.kde.kwrite.desktop" ];
      "application/x-docbook+xml" = [ "org.kde.kwrite.desktop" ];
      "application/x-yaml" = [ "org.kde.kwrite.desktop" ];
      "text/markdown" = [ "org.kde.kwrite.desktop" ];
      "text/plain" = [ "org.kde.kwrite.desktop" ];
      "text/html" = [ "librewolf.desktop" ];
      "x-scheme-handler/http" = [ "librewolf.desktop" ];
      "x-scheme-handler/https" = [ "librewolf.desktop" ];
      "x-scheme-handler/about" = [ "librewolf.desktop" ];
      "x-scheme-handler/unknown" = [ "librewolf.desktop" ];
      "x-scheme-handler/beeper" = [ "beepertexts.desktop" ];
      "x-scheme-handler/geo" = [ "openstreetmap-geo-handler.desktop" ];
      "x-scheme-handler/mailto" = [ "userapp-Thunderbird-DL6XQ3.desktop" ];
    };
  };
  home.preferXdgDirectories = true;*/
}