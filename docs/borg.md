# Commandes liées aux services borg

## Bypass l'authentification

Pour exécuter utiliser borg sans avoir à ressaisir le mot de passe à chaque fois :

```bash
sudo -i

export BORG_REPO="ssh://u502181-sub4@u502181-sub4.your-storagebox.de:23/./pc"
export BORG_RSH="ssh -i /var/lib/secrets/borg-ssh-key"
export BORG_PASSCOMMAND="cat /var/lib/secrets/borg-repo-password"
```

## Commandes BorgBackup usuelles

### Lister les archives

Lister toutes les archives existantes dans le dépôt :
```bash
borg list borg-repo:pc
```

Lister le contenu d'une archive :
```bash
borg list borg-repo:pc::<archive_id>
```

### Statistiques

Voir l'espace utilisé par le dépôt :
```bash
borg info borg-repo:pc
```

Voir l'espace utilisé par une archive :
```bash
borg info borg-repo:pc::<archive_id>
```

### Voir le contenu d'une archive

Monter l'ensemble du dépôt avec chaque archive :
```bash
mkdir -p ~/tmp/borg
borg mount borg-repo:pc ~/tmp/borg
```

Monter une archive spécifique :
```bash
borg mount borg-repo:pc::<archive_id> ~/tmp/borg
```

Démonter :
```bash
borg umount ~/tmp/borg
```

### Restaurer des fichiers

> L'extraction se fait du point de vue du répertoire courant !

Extraire toute l'archive :
```bash
borg extract borg-repo:pc::<archive_id>
```

Extraire uniquement un dossier précis :
```bash
borg extract borg-repo:pc::<archive_id> home/alex/folder
```

### Supprimer un fichier du dépôt

```bash
borg recreate --verbose --progress \
  --exclude 'home/alex/chemin/vers/truc-a-supprimer'
```


### Créer une sauvegarde manuellement

Pour lancer une sauvegarde manuelle avec les mêmes chemins et exclusions que la configuration automatique :
```bash
borg create --verbose --stats --progress \
  --compression auto,zstd,6 \
  --exclude-from /home/alex/.borg-exclude \
  ::manual-$(date +%Y-%m-%d-%H%M%S) \
  /home /var/lib/secrets
```

### Supprimer une archive spécifique

```bash
borg delete borg-repo:pc::<archive_id>
```

### Renommer une archive

```bash
borg rename borg-repo:pc::<archive_id_before> <archive_id_after>
```

### Supprimer d'anciennes archives

Suivant la configuration automatique : 
```bash
borg prune borg-repo:pc --dry-run --list \
  --keep-within 1d \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 6
```

### Comparer deux sauvegardes

Comparer le contenu de deux archives :
```bash
borg diff borg-repo:pc::<archive_id_before> <archive_id_after>
```

### Vérification & Maintenance

Vérifier l'intégrité du dépôt :
```bash
borg check borg-repo:pc
```

Libérer le verrou en cas d'interruption anormale (ex: crash machine, coupure réseau) :
```bash
borg break-lock borg-repo:pc
```

Libère les chunks inutiles après suppression de leurs archives :
```bash
borg compact borg-repo:pc
```

### Chiffrage

Modifier le mot de passe du dépôt : 
```bash
borg key borg-repo:pc change-passphrase
```
> Penser aussi à mettre à jour `/var/lib/secrets/borg-repo-password`

Exporter la clé du dépôt en cas de corruption du dépot distant : 
```bash
borg key export borg-repo:pc borg-repo-key-backup.txt

# ou en caractères lisibles
borg key export --paper borg-repo:pc
```
Puis importer la clé pour sauver le dépôt : 
```bash
borg key import borg-repo:pc borg-repo-key-backup.txt
```

## Gestion avec Systemd

### Automatisation

Lancer immédiatement la sauvegarde :
```bash
sudo systemctl start borgbackup-job-backup.service
```

Vérifier le statut du service :
```bash
systemctl status borgbackup-job-backup.service
```

Afficher les journaux en direct :
```bash
journalctl -u borgbackup-job-backup.service -f
```

Afficher l'historique des journaux :
```bash
journalctl -u borgbackup-job-backup.service
```

Voir la date de la prochaine exécution planifiée :
```bash
systemctl list-timers | grep borgbackup
```

### Tester les notifications de bureau

Tester la notification de succès :
```bash
sudo systemctl start borgbackup-job-backup-success-notify.service
```

Tester la notification d'échec :
```bash
sudo systemctl start borgbackup-job-backup-failure-notify.service
```
