{ config, lib, pkgs, ... }:

with lib;

let
  bannerFile = pkgs.writeText "initrd-banner.txt" ''
    ██▓▓  █▓▒░ ▄█▓▓▒░███▄ ██▓▓       ▄█▓▓▒░███▄      █▓▄   █▓▒░ ██▓▓ ██▓▓  ▓▒░█ ▄█▓▓▒░███▄ ▄▓▒░██▓▒░
    ▓▓▒▒  ▓▒░█ ▓▓▒▒  █░░█ ▓▓▒▒       ▓▓▒▒  █ ██      ▓▒░█▄ ▓▒░█ ▓▓▒▒ ▓▓▒▒  ▒░░█ ▓▓▒▒  █░░█ ▓▒░█
    ▒▒░░█░▒░▒█ ▒▒░░  █▒▒█ ▒▒░░       ▒▒░░██████      ▒░██▀░▒░▒█ ▒▒░░ ▀▒░░██░▒▒▀ ▒▒░░  █▒▒█ ▀░██████▄
    ░░██  ░▓▓  ░░██  █▓▓  ░░██  █▓▓█ ░░██  █▓▓█      ░███  ░▓▓█ ░░██ ░░██  █▓▓  ░░██  █▓▓       █░░█
    ████  ████ ▀████████▀ ▀█████████ ████  ████      ████  ████ ████ ████  ████ ▀████████▀ ░▒▓█████▀
  '';
in
{
  options.boot.customBanner.enable = mkEnableOption "Affiche la bannière ASCII dans l'initrd avant le déverrouillage LUKS";

  config = mkIf config.boot.customBanner.enable {
    # Embarque le fichier dans l'image initrd (car /etc/nixos n'est pas encore monté avant LUKS)
    boot.initrd.systemd.storePaths = [ bannerFile ];

    boot.initrd.systemd.services.show-banner = {
      description = "Affichage de la bannière personnalisée avant LUKS";
      wantedBy = [ "cryptsetup.target" "sysinit.target" ];
      before = [ "cryptsetup.target" "systemd-ask-password-console.service" ];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        StandardOutput = "tty";
        TTYPath = "/dev/console";
        ExecStart = "/bin/cat ${bannerFile}";
      };
    };
  };
}
