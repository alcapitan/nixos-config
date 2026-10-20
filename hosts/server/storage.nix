{ pkgs, lib, config, ... }:

{
  environment.systemPackages = [ pkgs.cifs-utils pkgs.sshfs ];

  systemd.tmpfiles.rules = [
    "d /mnt/storagebox 0755 root root -"
  ];

  sops.secrets."storagebox/username" = {
    sopsFile = ./credentials.yaml;
  };
  sops.secrets."storagebox/password" = {
    sopsFile = ./credentials.yaml;
  };
  # clé ssh du vps ansible
  sops.secrets."storagebox/ssh_key" = {
    sopsFile = ./credentials.yaml;
    owner = "root";
    group = "root";
    mode = "0400";
  };

  sops.templates."storagebox-credentials" = {
    content = ''
      username=${config.sops.placeholder."storagebox/username"}
      password=${config.sops.placeholder."storagebox/password"}
    '';
    path = "/var/lib/secrets/storagebox";
    owner = "root";
    group = "root";
    mode = "0400";
  };

  # * nix run nixpkgs#sshfs -- u502181-sub5@u502181-sub5.your-storagebox.de: ~/tmp/cifs -p 23 -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 ; fusermount3 -u ~/tmp/cifs
  # * sudo mount -t cifs //u502181-sub5.your-storagebox.de/u502181-sub5 ~/tmp/cifs -o username=u502181-sub5,uid=1000,gid=1000,file_mode=0770,dir_mode=0770,nounix,noserverino,nobrl,cache=none,vers=3.0

  # --- Variante CIFS (désactivée) ---
  # systemd.mounts plutôt que fileSystems : le module qemu-vm (system.build.vm)
  # écrase fileSystems, alors que les unités systemd sont conservées.
  #
  # systemd.mounts = [{
  #     what = "//u502181-sub5.your-storagebox.de/u502181-sub5";
  #     where = "/mnt/storagebox";
  #     type = "cifs";
  #     options = lib.concatStringsSep "," [
  #         "credentials=${config.sops.templates."storagebox-credentials".path}"
  #         "uid=1000"
  #         "gid=1000"
  #         "file_mode=0770"
  #         "dir_mode=0770"
  #         "nounix"
  #         "noserverino"
  #         "nobrl"
  #         "cache=none"
  #         "vers=3.0"
  #         "_netdev"
  #     ];
  #     wants = [ "network-online.target" ];
  #     after = [ "network-online.target" ];
  # }];
  #
  # systemd.automounts = [{
  #     where = "/mnt/storagebox";
  #     wantedBy = [ "multi-user.target" ];
  #     automountConfig.TimeoutIdleSec = "60";
  # }];

  # --- Variante SSHFS (active) ---
  systemd.mounts = [
    {
      what = "u502181-sub5@u502181-sub5.your-storagebox.de:";
      where = "/mnt/storagebox";
      type = "sshfs";
      options = lib.concatStringsSep "," [
        "port=23"
        "IdentityFile=${config.sops.secrets."storagebox/ssh_key".path}"
        "ssh_command=${pkgs.openssh}/bin/ssh"
        # Pas de prompt interactif ; la clé d'hôte est mémorisée au premier accès
        "StrictHostKeyChecking=accept-new"
        "UserKnownHostsFile=/var/lib/storagebox-known_hosts"
        "BatchMode=yes"
        # Reconnexion et détection de coupure réseau
        "reconnect"
        "ServerAliveInterval=15"
        "ServerAliveCountMax=3"
        # Droits côté local
        "allow_other"
        "idmap=user"
        "uid=1000"
        "gid=1000"
        "_netdev"
      ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
    }
  ];

  systemd.automounts = [
    {
      where = "/mnt/storagebox";
      wantedBy = [ "multi-user.target" ];
      automountConfig.TimeoutIdleSec = "60";
    }
  ];
}
