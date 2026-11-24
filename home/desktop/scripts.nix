{ pkgs, pkgs-unstable, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "ytm-download" ''
      set -euo pipefail

      if [ -z "$1" ]; then
        echo "Usage: ytm-download <URL_OU_FICHIER.txt_OU_RECHERCHE>"
        exit 1
      fi

      YTDLP_ARGS=(
        -f "bestaudio"
        --extract-audio
        --audio-format best
        --audio-quality 0
        --embed-metadata
        --add-metadata
        --embed-thumbnail
        --embed-chapters
        --ppa "ThumbnailsConvertor:-vf crop='min(iw\,ih)':'min(iw\,ih)'"
        --extractor-args "youtube:player_client=web_music"
        --parse-metadata "%(channel)s:%(artist)s"
        --replace-in-metadata "artist,channel,uploader" "\s*-\s*Topic$" ""
        --replace-in-metadata "title" "(?i)\s*[\(\[][^\)\]]*(official|lyric|audio|video|remix|visualizer|explicit|hd|4k|mv)[^\)\]]*[\)\]]\s*" ""
        --downloader ffmpeg
        --concurrent-fragments 1
        --no-post-overwrites
        --ignore-errors
        -o "%(artist,channel,uploader)s - %(title)s.%(ext)s"
      )

      if [ -f "$1" ]; then
        echo "Téléchargement à partir du fichier texte : $1"
        ${pkgs-unstable.yt-dlp}/bin/yt-dlp \
          --batch-file "$1" \
          --default-search "ytsearch1" \
          "''${YTDLP_ARGS[@]}"
      else
        # Si c'est une URL directe (playlist ou vidéo)
        ${pkgs-unstable.yt-dlp}/bin/yt-dlp \
          --default-search "ytsearch1" \
          "''${YTDLP_ARGS[@]}" \
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
}
