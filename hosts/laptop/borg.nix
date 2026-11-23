{ config, pkgs, ... }:

{
  # TODO: finir de clean les fichiers suivis dont les projets dev old et le scolaire et les jeux (conserver les sauvegardes !!)

  services.borgbackup.jobs."backup" = {
    repo = "ssh://u502181-sub4@u502181-sub4.your-storagebox.de:23/./pc";
    doInit = false;

    # Options SSH de résilience :
    # - ConnectTimeout=30 : évite d'attendre 2+ minutes si le serveur est injoignable
    # - ServerAliveInterval=15 : envoie un ping toutes les 15s pour maintenir la connexion active
    # - ServerAliveCountMax=3 : après 45s sans réponse (15s x 3), coupe la connexion proprement
    environment.BORG_RSH = "ssh -i /var/lib/secrets/borg-ssh-key -o ConnectTimeout=30 -o ServerAliveInterval=15 -o ServerAliveCountMax=3";

    extraCreateArgs = "--one-file-system --verbose --stats --exclude-from /home/alex/.borg-exclude "; # --one-file-system empêche de sauvegarder des montages distants
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

    # Désactive le timer automatique par défaut pour empêcher les rattrapages intempestifs au boot
    startAt = [ ];

    # Teste la joignabilité réelle du serveur
    preHook = ''
      HOST="u502181-sub4.your-storagebox.de"
      PORT=23
      MAX_WAIT=90
      WAIT=0

      echo "Attente de la disponibilité du serveur Borg ($HOST:$PORT)..."
      while ! ${pkgs.netcat}/bin/nc -z -w 3 "$HOST" "$PORT" 2>/dev/null; do
        if [ "$WAIT" -ge "$MAX_WAIT" ]; then
          echo "Délai dépassé ($MAX_WAIT s) : serveur Borg injoignable ou hors-ligne."
          exit 1
        fi
        sleep 5
        WAIT=$((WAIT + 5))
      done
      echo "Connexion établie et stabilisée vers $HOST:$PORT."
    '';

    archiveBaseName = null;
    dateFormat = "+%Y-%m-%d_%H:%M:%S";

    # En cas de succès ($exitStatus == 0), on enregistre la date du jour.
    # Ce fichier (/root/.cache/borg/last-backup-date) est consulté par le timer
    # automatique pour éviter d'exécuter plus d'une sauvegarde par jour.
    postHook = ''
      if [ "$exitStatus" -eq 0 ]; then
        ${pkgs.coreutils}/bin/date +%Y-%m-%d > /root/.cache/borg/last-backup-date
      fi
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

  # Timer système déclenché par la session utilisateur :
  # - wantedBy & partOf user@1000.service : lie l'activation du timer à la connexion de l'utilisateur alex (UID 1000), plutôt qu'au boot brut de la machine.
  # - OnActiveSec = "1min" : déclenche le service 1 minute après l'ouverture de session.
  # - Unit = "borgbackup-job-backup-scheduled.service" : appelle le service intermédiaire qui vérifie si une sauvegarde a déjà eu lieu aujourd'hui.
  systemd.timers."borgbackup-job-backup" = {
    wantedBy = [ "user@1000.service" ];
    partOf = [ "user@1000.service" ];
    timerConfig = {
      OnActiveSec = "1min";
      Unit = "borgbackup-job-backup-scheduled.service";
    };
  };

  # Vérifie si une sauvegarde a déjà été effectuée aujourd'hui. Si oui, il est ignoré proprement (ExecCondition).
  # Si non, il lance le vrai service `borgbackup-job-backup.service`.
  # Ainsi, un lancement manuel via `systemctl start borgbackup-job-backup.service` court-circuite cette vérification !
  systemd.services."borgbackup-job-backup-scheduled" = {
    description = "Déclencheur automatique quotidien de BorgBackup";
    serviceConfig = {
      Type = "oneshot";
      ExecCondition = pkgs.writeShellScript "check-borg-backup-today" ''
        MARKER="/root/.cache/borg/last-backup-date"
        TODAY=$(${pkgs.coreutils}/bin/date +%Y-%m-%d)
        if [ -f "$MARKER" ] && [ "$(${pkgs.coreutils}/bin/cat "$MARKER")" = "$TODAY" ]; then
          echo "BorgBackup: Sauvegarde déjà effectuée aujourd'hui ($TODAY), ignorée."
          exit 1
        fi
        exit 0
      '';
      ExecStart = "${pkgs.systemd}/bin/systemctl start --wait borgbackup-job-backup.service";
    };
  };

  # Service principal de sauvegarde :
  # Peut être démarré manuellement sans restriction : `sudo systemctl start borgbackup-job-backup.service`
  systemd.services."borgbackup-job-backup" = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    onFailure = [ "borgbackup-job-backup-failure-notify.service" ];

    unitConfig = {
      OnSuccess = [ "borgbackup-job-backup-success-notify.service" ];
    };

    serviceConfig = {
      # En cas d'échec (ex: pas d'Internet au login ou coupure), réessayer 5 minutes plus tard
      Restart = "on-failure";
      RestartSec = "5min";
    };

    restartIfChanged = false;
    stopIfChanged = false;
  };

  # Notifications graphiques transmises à la session de l'utilisateur alex via libnotify
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
