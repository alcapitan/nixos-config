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
    # pkgs-unstable.zed-editor
    beeper
    discord
    pkgs-unstable.proton-authenticator
    organicmaps

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

  # * cat ~/.config/zed/settings.json
  # ! TODO: zed ne pourra plus modifier ses paramètres après que le fichier de config actuel soit supprimé
  programs.zed-editor = {
    enable = true;
    userSettings = {
      auto_install_extensions = {
        nix = true;
        html = true;
        dockerfile = true;
        comment = true;
        git-firefly = true;
        material-icon-theme = true;
      };
      diff_view_style = "split";
      cli_default_open_behavior = "existing_window";
      icon_theme = "Material Icon Theme";
      agent = {
        button = false;
      };
      collaboration_panel.button = false;
      outline_panel.button = false;
      git_panel = {
        group_by = "staging";
        collapse_untracked_diff = false;
        button = true;
        status_style = "label_color";
        dock = "left";
        tree_view = true;
      };
      project_panel = {
        hide_root = true;
        git_status_indicator = false;
        bold_folder_labels = false;
        git_status = true;
        folder_icons = true;
        file_icons = true;
        entry_spacing = "comfortable";
        dock = "left";
      };
      colorize_brackets = true;
      toolbar = {
        agent_review = true;
        quick_actions = true;
        breadcrumbs = true;
      };
      minimap.show = "always";
      gutter.line_numbers = true;
      autosave = "on_window_change";
      ui_font_size = 16;
      buffer_font_size = 15;
      theme = {
        mode = "system";
        light = "One Light";
        dark = "One Dark";
      };
    };
  };

  # Applications par défaut
  # * cat ~/.config/mimeapps.list
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/jpeg" = [ "org.kde.koko.desktop" ];
      "image/png" = [ "org.kde.koko.desktop" ];
      "image/webp" = [ "org.kde.koko.desktop" ];
      "image/gif" = [ "org.kde.koko.desktop" ];
      "image/bmp" = [ "org.kde.koko.desktop" ];
      "image/tiff" = [ "org.kde.koko.desktop" ];
      "image/avif" = [ "org.kde.koko.desktop" ];
      "image/heic" = [ "org.kde.koko.desktop" ];
      "image/heif" = [ "org.kde.koko.desktop" ];

      "video/mp4" = [ "vlc.desktop" ];
      "video/x-matroska" = [ "vlc.desktop" ];
      "video/webm" = [ "vlc.desktop" ];
      "video/vnd.avi" = [ "vlc.desktop" ]; # AVI
      "video/quicktime" = [ "vlc.desktop" ]; # MOV
      "video/mpeg" = [ "vlc.desktop" ];
      "video/ogg" = [ "vlc.desktop" ];

      "audio/mpeg" = [ "vlc.desktop" ]; # MP3
      "audio/mp3" = [ "vlc.desktop" ];
      "audio/mp4" = [ "vlc.desktop" ]; # M4A / AAC
      "audio/aac" = [ "vlc.desktop" ];
      "audio/flac" = [ "vlc.desktop" ];
      "audio/ogg" = [ "vlc.desktop" ];
      "audio/opus" = [ "vlc.desktop" ];
      "audio/wav" = [ "vlc.desktop" ];
      "audio/webm" = [ "vlc.desktop" ];

      "application/pdf" = [ "org.kde.okular.desktop" ];
      "application/vnd.oasis.opendocument.text" = [ "writer.desktop" ]; # ODT
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ]; # DOCX
      "application/msword" = [ "writer.desktop" ]; # DOC
      "application/rtf" = [ "writer.desktop" ];
      "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ]; # ODS
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "calc.desktop" ]; # XLSX
      "application/vnd.ms-excel" = [ "calc.desktop" ]; # XLS
      "text/csv" = [ "calc.desktop" ];
      "application/vnd.oasis.opendocument.presentation" = [ "impress.desktop" ]; # ODP
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [ "impress.desktop" ]; # PPTX
      "application/vnd.ms-powerpoint" = [ "impress.desktop" ]; # PPT

      "application/json" = [ "org.kde.kwrite.desktop" ];
      "application/xml" = [ "org.kde.kwrite.desktop" ];
      "application/yaml" = [ "org.kde.kwrite.desktop" ];
      "text/markdown" = [ "org.kde.kwrite.desktop" ];
      "text/plain" = [ "org.kde.kwrite.desktop" ];
      "text/html" = [ "librewolf.desktop" ];
      "application/vnd.ms-publisher" = [ "org.kde.kwrite.desktop" ]; # PUB ssh instead of ms publisher

      "application/zip" = [ "org.kde.ark.desktop" ];
      "application/x-tar" = [ "org.kde.ark.desktop" ];
      "application/x-compressed-tar" = [ "org.kde.ark.desktop" ];
      "application/gzip" = [ "org.kde.ark.desktop" ];
      "application/x-xz" = [ "org.kde.ark.desktop" ];
      "application/x-xz-compressed-tar" = [ "org.kde.ark.desktop" ];
      "application/x-7z-compressed" = [ "org.kde.ark.desktop" ];
      "application/vnd.rar" = [ "org.kde.ark.desktop" ];
      "application/x-rar" = [ "org.kde.ark.desktop" ];
      "application/zstd" = [ "org.kde.ark.desktop" ];
      "application/x-zstd" = [ "org.kde.ark.desktop" ];

      "x-scheme-handler/http" = [ "librewolf.desktop" ];
      "x-scheme-handler/https" = [ "librewolf.desktop" ];
      "x-scheme-handler/about" = [ "librewolf.desktop" ];
      "x-scheme-handler/unknown" = [ "librewolf.desktop" ];
      "x-scheme-handler/beeper" = [ "beepertexts.desktop" ];
      "x-scheme-handler/geo" = [ "openstreetmap-geo-handler.desktop" ];
      "inode/directory" = [ "org.kde.dolphin.desktop" ];
      "x-scheme-handler/mailto" = [ "userapp-Thunderbird-CMC7R3.desktop" ];
      "x-scheme-handler/mid" = [ "userapp-Thunderbird-CMC7R3.desktop" ];
      "message/rfc822" = [ "userapp-Thunderbird-CMC7R3.desktop" ];
    };
  };
  home.preferXdgDirectories = true;
  xdg.configFile."mimeapps.list".force = true; # ! destructif ; rm ~/.config/mimeapps.list
  xdg.dataFile."applications/mimeapps.list".force = true;

  # Démarrage automatique d'application au démarrage de la session user
  xdg.configFile."autostart/proton.vpn.app.gtk.desktop".source = "${pkgs.proton-vpn}/share/applications/proton.vpn.app.gtk.desktop";
}
