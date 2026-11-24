{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "copy" ''
      if [ -n "$WAYLAND_DISPLAY" ]; then
        # retire le saut de ligne en fin s'il existe
        exec wl-copy -n
      else
        # Détermination du chemin du fichier
        if [ -d "$HOME/tmp" ]; then
          CLIP_FILE="$HOME/tmp/clip.txt"
        else
          CLIP_FILE="/tmp/clip.txt"
        fi

        # retire le saut de ligne en fin (pour tty)
        # CONTENT=$(cat)
        # Écrit la sortie de la commande dans le fichier (le crée s'il n'existe pas)
        cat > "$CLIP_FILE"
        echo "Copié dans $CLIP_FILE" >&2
      fi
    '')

    (pkgs.writeShellScriptBin "paste" ''
      if [ -n "$WAYLAND_DISPLAY" ]; then
        exec wl-paste
      else
        # Détermination du même chemin
        if [ -d "$HOME/tmp" ]; then
          CLIP_FILE="$HOME/tmp/clip.txt"
        else
          CLIP_FILE="/tmp/clip.txt"
        fi

        # Vérifie si le fichier existe et n'est pas vide avant de l'afficher
        if [ -f "$CLIP_FILE" ]; then
          cat "$CLIP_FILE"
        else
          echo "Presse-papier vide" >&2
        fi
      fi
    '')
  ];
}
