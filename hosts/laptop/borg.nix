{ config, pkgs, ... }:

{
  systemd.services."borgbackup-job-backup".unitConfig.OnFailure = "borg-failure-notify.service";

  systemd.services."borg-failure-notify" = {
    description = "Notification graphique d'échec Borg";
    script = ''
      # On force l'exécution dans le contexte de ta session utilisateur graphique (ID 1000)
      /run/current-system/sw/bin/systemd-run --user -M alex@ --collect \
        ${pkgs.libnotify}/bin/notify-send --urgency=critical "❌ Échec du Backup Borg" "Le job de sauvegarde a planté. Vérifie les logs avec journalctl."
    '';
  };

  services.borgbackup.jobs."backup" = {
    repo = "ssh://u502181-sub4@u502181-sub4.your-storagebox.de:23/./pc";

    doInit = false;

    environment.BORG_RSH = "ssh -i /var/lib/secrets/borg-ssh-key";
    extraCreateArgs = "--verbose --stats --exclude-from /home/alex/.borg-exclude";

    paths = [
      "/home"
      "/var/lib/secrets"
    ];

    failOnWarnings = false;

    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /var/lib/secrets/borg-repo-password";
    };

    compression = "auto,zstd,6";
    startAt = "daily";

    postHook = ''
      /run/current-system/sw/bin/systemd-run --user -M alex@ --collect \
        ${pkgs.libnotify}/bin/notify-send --urgency=normal "✅ Backup Borg Réussi" "Toutes tes données sont à l'abri sur Hetzner."
    '';

    prune = {
      keep = {
        within = "1d";
        daily = 7;
        weekly = 4;
        monthly = 6;
      };
    };
    extraPruneArgs = "--verbose --list";
  };

  systemd.services."borgbackup-job-backup" = {
    requires = [ "network-online.target" ];

    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "1m";
    };
  };
}
