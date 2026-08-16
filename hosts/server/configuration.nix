{ pkgs, ... }:

{
  imports = [
    # ./hardware-configuration.nix
    ./test_env.nix
    ./services.nix
    ./storage.nix
    # ./borg.nix
  ];

  networking.hostName = "vps";
  networking.useDHCP = true;
  system.stateVersion = "25.11";
  
  console.earlySetup = true;
  boot.kernelParams = [ "numlock=on" ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 
      2222 # ssh authentification
      22 # ssh forjego
      80
      443
      53 # Adguard DNS
    ];
    allowedUDPPorts = [ 
      443 # pour Cloudflare et HTTP3 # TODO: à déprécier ?
      53 # Adguard DNS
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
  # Libère le port 53 aussi occupé par le résolveur inter-containeur podman
  virtualisation.containers.containersConf.settings = {
    network = {
      dns_bind_port = 5353;
    };
  };

  # Restreindre la visibilité des processus (hidepid=2)
  security.protectKernelImage = true;
  /*fileSystems."/proc" = { # TODO: à supprimer ou remanier
    device = "proc";
    fsType = "proc";
    options = [ "nosuid" "nodev" "noexec" "hidepid=2" ];
  };*/

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "04:30"; # Tous les jours
    flake = "github:alcapitan/nixos-config#vps";
  };

  # Rétention / Garbage Collector
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/srv/adguardhome/work 0755 root root -"
    "d /var/lib/srv/adguardhome/conf 0755 root root -"
    "d /var/lib/srv/radicale/data 0770 2999 2999 -" # radicale user uid
    "d /var/lib/srv/radicale/config 0755 root root -"
    ''f+ /var/lib/srv/radicale/config/config 0644 root root - [server]\nhosts = 0.0.0.0:5232\n\n[storage]\ntype = multifilesystem\nfilesystem_folder = /data/collections\n\n[auth]\ntype = htpasswd\nhtpasswd_filename = /config/users\nhtpasswd_encryption = bcrypt\n'' # TODO: à remanier dans un fichier
    "d /var/lib/srv/forgejo/data 0755 1082 1082 -" # uid de git dans forjego
  ];

  /* # quotas

  fileSystems."/" = {
    options = [ "defaults" "usrquota" ];
  };

  security.pam.loginLimits = [
    { domain = "*"; type = "soft"; item = "nproc"; value = "100"; } # pas plus de 100 processus par user
    { domain = "*"; type = "hard"; item = "nproc"; value = "300"; } # pas plus de 300 processus par user
    { domain = "*"; type = "soft"; item = "fsize"; value = "3145728"; } # taille max fichier 3 Go
    { domain = "*"; type = "hard"; item = "fsize"; value = "6291456"; } # taille max fichier 6 Go
    { domain = "*"; type = "hard"; item = "memlock"; value = "524288"; } # pas plus de 512Mo RAM par user
    { domain = "*"; type = "hard"; item = "cpu"; value = "30"; } # pas plus de 30 minutes de CPU
    { domain = "root"; type = "hard"; item = "nproc"; value = "unlimited"; } # désactive restriction processus pour root
    { domain = "root"; type = "soft"; item = "nproc"; value = "unlimited"; }
  ];*/
}