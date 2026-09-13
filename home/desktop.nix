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
    pkgs-unstable.yt-dlp

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

        ${pkgs-unstable.yt-dlp}/bin/yt-dlp \
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
        ${pkgs-unstable.yt-dlp}/bin/yt-dlp \
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

    (pkgs.writeScriptBin "unlock" ''
        #!${pkgs.zsh}/bin/zsh

        setopt ERR_EXIT         # Arrête le script si une commande échoue
        setopt NO_UNSET         # Erreur si une variable non définie est lue
        setopt PIPE_FAIL        # Propage les erreurs à travers les pipes

        # Vérifie si un fichier gpg est passé en paramètre
        if [[ $# -ne 1 ]]; then
          print -u2 "Usage: unlock <path-to-gpg>"
          exit 1
        fi

        # :A résout le chemin absolu et suit les liens symboliques en Zsh
        SRC_FILE="''${1:A}"
        if [[ ! -f "$SRC_FILE" ]]; then
          print -u2 "Erreur : Fichier introuvable : $SRC_FILE"
          exit 1
        fi

        # Identité GPG pour le rechiffrement
        GPG_RECIPIENT="alexandre.boyer29@gmail.com"

        WORKDIR="/home/$USER/tmp/unlock"
        DATA_DIR="$WORKDIR/content"

        # Nettoyage initial et création de l'espace de travail
        rm -rf "$WORKDIR"
        mkdir -p "$DATA_DIR"

        # Trap Zsh exécuté automatiquement à la fin du script
        TRAPEXIT() {
          rm -rf "$WORKDIR"
        }

        print -P "%F{green}==> Copie de l'archive chiffrée...%f"
        cp "$SRC_FILE" "$WORKDIR/secret.tar.gz.gpg"

        print -P "%F{green}==> Déchiffrement...%f"
        ${pkgs.gnupg}/bin/gpg --quiet --decrypt "$WORKDIR/secret.tar.gz.gpg" > "$WORKDIR/secret.tar.gz"

        print -P "%F{green}==> Extraction...%f"
        ${pkgs.gnutar}/bin/tar -xzf "$WORKDIR/secret.tar.gz" -C "$DATA_DIR"

        # Suppression de l'archive temporaire avant modification
        rm -f "$WORKDIR/secret.tar.gz" "$WORKDIR/secret.tar.gz.gpg"

        print -P "%F{yellow}==> Ouverture du shell (tapez 'exit' ou Ctrl+D pour terminer)...%f"
        (
          cd "$DATA_DIR"
          exec "''${SHELL:-${pkgs.zsh}/bin/zsh}"
        )

        print -P "%F{green}==> Recompression de l'archive...%f"
        ${pkgs.gnutar}/bin/tar -czf "$WORKDIR/secret.tar.gz" -C "$DATA_DIR" .

        print -P "%F{green}==> Rechiffrement pour $GPG_RECIPIENT...%f"
        ${pkgs.gnupg}/bin/gpg --quiet --yes --encrypt --recipient "$GPG_RECIPIENT" \
          --output "$WORKDIR/secret.tar.gz.gpg" "$WORKDIR/secret.tar.gz"

        print -P "%F{green}==> Remplacement du fichier d'origine...%f"
        mv "$WORKDIR/secret.tar.gz.gpg" "$SRC_FILE"

        print -P "%F{blue}==> Terminé avec succès !%f"
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
