{ config, lib, pkgs, ... }:

{
  imports = [
    # ./hardware-configuration.nix
    ./test_env.nix
    ./services
    ./storage.nix
  ];

  options.security.serverHardening.enable = lib.mkEnableOption "Active le durcissement supplémentaire du serveur (hidepid=2 sur /proc et limites PAM)";

  config = lib.mkMerge [
    {
      networking.hostName = "server";
      networking.useDHCP = true;
      system.stateVersion = "25.11";

      console.earlySetup = true;
      boot.kernelParams = [ "numlock=on" ];

      # Durcissement supplémentaire désactivé par défaut (sensible pour les conteneurs rootless et PostgreSQL)
      security.serverHardening.enable = false;

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [
          2222 # ssh authentification
          22   # ssh forgejo
          80
          443
          53   # Adguard DNS
        ];
        allowedUDPPorts = [
          443  # HTTP/3 (QUIC) pour Caddy
          53   # Adguard DNS
        ];
      };

      services.openssh = {
        enable = true;
        ports = [ 2222 ];
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "no";
        };
      };

      services.fail2ban = {
        enable = true;
      };

      services.resolved.enable = false; # Désactive le résolveur DNS commun pour Adguard
      # Libère le port 53 aussi occupé par le résolveur inter-conteneur podman
      virtualisation.containers.containersConf.settings = {
        network = {
          dns_bind_port = 5353;
        };
      };

      security.protectKernelImage = true;

      system.autoUpgrade = {
        enable = true;
        allowReboot = true;
        dates = "04:30"; # Tous les jours
        flake = "github:alcapitan/nixos-config#server";
      };

      # Rétention / Garbage Collector
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      # Sauvegarde automatisée BorgBackup (désactivée en VM de test tant que le dépôt distant n'est pas initialisé)
      services.myBorg = {
        enable = false; # TODO: créer le dossier server-test sur hetzner sftp puis passer à true
        repoSubdir = "server-test";
        paths = [
          "/etc/nixos"
          "/var/lib/secrets"
          "/var/lib/srv"   # Les données des containers
          "/var/lib/caddy" # Certificats et état de Caddy
          "/root"          # Éventuels scripts d'admin
        ];
        extraCreateArgs = ''
          --one-file-system --verbose --stats \
          --exclude /var/log \
          --exclude /var/cache \
          --exclude /var/tmp \
          --exclude /var/lib/docker/containers \
          --exclude /var/lib/containers/storage
        '';
        keepMonthly = 12; # On garde 12 mois pour un serveur, au cas où
        triggerOnUserLogin = false;
        desktopNotifications = false;
      };
    }

    (lib.mkIf config.security.serverHardening.enable {
      # Restreindre la visibilité des processus aux seuls propriétaires (et groupe wheel)
      fileSystems."/proc" = {
        device = "proc";
        fsType = "proc";
        options = [ "nosuid" "nodev" "noexec" "hidepid=2" "gid=wheel" ];
      };

      # Limites de ressources PAM pour les sessions utilisateurs non-root
      security.pam.loginLimits = [
        { domain = "*"; type = "soft"; item = "nproc"; value = "250"; }
        { domain = "*"; type = "hard"; item = "nproc"; value = "500"; }
        { domain = "*"; type = "soft"; item = "fsize"; value = "3145728"; } # 3 Go
        { domain = "*"; type = "hard"; item = "fsize"; value = "6291456"; } # 6 Go
        { domain = "root"; type = "hard"; item = "nproc"; value = "unlimited"; }
        { domain = "root"; type = "soft"; item = "nproc"; value = "unlimited"; }
      ];
    })
  ];
}
