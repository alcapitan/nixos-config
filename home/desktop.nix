{ config, pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./plasma.nix
  ];

  home.packages = with pkgs; [
    # Applications principales
    brave #! deprecated
    firefox #! deprecated
    # librewolf
    thunderbird
    libreoffice-qt
    vlc
    vscode #! deprecated
    pkgs-unstable.zed-editor
    beeper
    discord
    pkgs-unstable.proton-authenticator

    # Design / Multimédia
    inkscape
    gimp
    parabolic
    tagger

    # Outils Dev / Docs
    # android-studio # TODO: installer flutter
    pdftk
    imagemagick

    pkgs-unstable.cloudflared

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

  # Applications par défaut
  #* cat ~/.config/mimeapps.list
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
      "x-scheme-handler/mailto" = [ "userapp-Thunderbird-CMC7R3.desktop" ];
      "x-scheme-handler/mid" = [ "userapp-Thunderbird-CMC7R3.desktop" ];
      "message/rfc822" = [ "userapp-Thunderbird-CMC7R3.desktop" ];
      # TODO: gérer fichiers pub (clés ssh publiques qui s'ouvrent sur libreoffice draw)
    };
  };
  home.preferXdgDirectories = true;
  xdg.configFile."mimeapps.list".force = true; #! destructif ; rm ~/.config/mimeapps.list
  xdg.dataFile."applications/mimeapps.list".force = true;

  # Démarrage automatique d'application au démarrage de la session user
  xdg.configFile."autostart/proton.vpn.app.gtk.desktop".source = "${pkgs.proton-vpn}/share/applications/proton.vpn.app.gtk.desktop";
}
