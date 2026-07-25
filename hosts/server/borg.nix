{ config, pkgs, ... }:

{
  services.borgbackup.jobs."backup" = {
    # Nouveau sous-dossier dédié au VPS sur ta Storage Box
    repo = "ssh://u502181-sub4@u502181-sub4.your-storagebox.de:23/./server-test"; # TODO: créer le dossier sur hetzner sftp

    doInit = false;

    environment.BORG_RSH = "ssh -i /var/lib/secrets/borg-ssh-key";

    # Exclusions adaptées aux serveurs (logs, caches, sockets...)
    extraCreateArgs = ''
      --exclude /var/log \
      --exclude /var/cache \
      --exclude /var/tmp \
      --exclude /var/lib/docker/containers \
      --exclude /var/lib/containers/storage
    '';

    # Dossiers clés à sauvegarder sur le VPS
    paths = [
      "/etc/nixos"
      "/var/lib/secrets"
      "/var/lib/srv" # Les données des containers
      "/var/lib/caddy" # Certificats et état de Caddy
      "/root" # Éventuels scripts d'admin
    ];

    failOnWarnings = false;

    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /var/lib/secrets/borg-repo-password";
    };

    compression = "auto,zstd,6";
    startAt = "daily";

    prune = {
      keep = {
        within = "1d";
        daily = 7;
        weekly = 4;
        monthly = 12; # On garde 12 mois pour un serveur, au cas où
      };
    };
  };

  systemd.services."borgbackup-job-backup" = {
    requires = [ "network-online.target" ];

    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5m"; # 5 minutes sur serveur pour laisser le réseau se stabiliser en cas de micro-coupure
    };
  };
}