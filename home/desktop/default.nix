{ config, pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./plasma.nix
    ./librewolf.nix
    ./zed.nix
    ./mime.nix
    ./scripts.nix
    ./thunderbird.nix
  ];

  # Options de modules utilisateurs (désactivées par défaut tant que non validées)
  my.thunderbird.enable = false;

  home.packages = with pkgs; [
    # Applications principales
    brave # ! deprecated
    firefox # ! deprecated
    # librewolf
    thunderbird
    libreoffice-qt
    vlc # mpv / cmus
    pkgs-unstable.vscode # ! deprecated
    beeper
    discord
    pkgs-unstable.proton-authenticator
    organicmaps
    qgis
    rustdesk
    filezilla

    # Design / Multimédia
    inkscape
    gimp
    parabolic
    tagger
    pkgs-unstable.yt-dlp

    # Outils Dev / Docs
    android-studio
    flutter
    jdk
    pdftk
    imagemagick
    nerd-fonts.jetbrains-mono
    pkgs-unstable.claude-code
    pkgs-unstable.antigravity-cli
    pkgs-unstable.antigravity-ide
    pkgs-unstable.antigravity-hub
  ];

  # Démarrage automatique d'application au démarrage de la session user
  xdg.configFile."autostart/proton.vpn.app.gtk.desktop".source = "${pkgs-unstable.proton-vpn}/share/applications/proton.vpn.app.gtk.desktop";
  xdg.configFile."autostart/beepertexts.desktop".source = "${pkgs.beeper}/share/applications/beepertexts.desktop";

  # pour le développement android
  home.sessionVariables = {
    JAVA_HOME = "${pkgs.jdk}";
    CHROME_EXECUTABLE = "${pkgs.brave}/bin/brave";
    DART_SDK = "${pkgs.flutter}/bin/cache/dart-sdk";
  };
  home.file.".local/share/dart-sdk".source = "${pkgs.flutter}/bin/cache/dart-sdk"; # un chemin fixe pour que android studio sache retrouver dart sdk
  home.file.".local/share/flutter".source = pkgs.flutter;
}
