{ config, pkgs, ... }:

{
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
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];

        onFailure = [ "borgbackup-job-backup-failure-notify.service" ];

        unitConfig = {
            OnSuccess = [ "borgbackup-job-backup-success-notify.service" ];
        };

        serviceConfig = {
            Restart = "on-failure";
            RestartSec = "5min";
        };

        restartIfChanged = false;
        stopIfChanged = false;
    };

    systemd.services."borgbackup-job-backup-success-notify" = {
        description = "Notify user on borg backup success";
        serviceConfig = {
        Type = "oneshot";
        ExecStart = ''
            /run/current-system/sw/bin/systemd-run --user -M alex@ --collect \
            ${pkgs.libnotify}/bin/notify-send --urgency=normal "✅ Sauvegarde Borg réussi" "borg list borg-repo:pc"
        '';
        };

        restartIfChanged = false;
        stopIfChanged = false;
    };

    systemd.services."borgbackup-job-backup-failure-notify" = {
        description = "Notify user on borg backup failure";
        serviceConfig = {
            Type = "oneshot";
            ExecStart = ''
                /run/current-system/sw/bin/systemd-run --user -M alex@ --collect \
                ${pkgs.libnotify}/bin/notify-send --urgency=critical "❌ Échec de la sauvegarde Borg" "journalctl -u borgbackup-job-backup"
            '';
        };

        restartIfChanged = false;
        stopIfChanged = false;
    };
}