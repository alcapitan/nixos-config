{ pkgs, ... }:

{
  imports = [
    # ./hardware-configuration.nix
    # ./borg.nix
  ];

  networking.hostName = "vps";
  networking.useDHCP = true;
  system.stateVersion = "25.11";
  
  console.earlySetup = true;
  boot.kernelParams = [ "numlock=on" ];

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096; # 4 GB RAM
      cores = 2;         # 2 vCPU
      diskSize = 40900;  # 40 GB Disk

      # graphics = false;

      forwardPorts = [
        { from = "host"; host.address = "127.1.0.1"; host.port = 8000; guest.port = 80; }
        { from = "host"; host.address = "127.1.0.1"; host.port = 8443; guest.port = 443; }
        { from = "host"; host.address = "127.1.0.1"; host.port = 2222; guest.port = 2222; }
        { proto = "tcp"; from = "host"; host.address = "127.1.0.1"; host.port = 5353; guest.port = 53; }
        { proto = "udp"; from = "host"; host.address = "127.1.0.1"; host.port = 5353; guest.port = 53; }
      ];
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 
      2222
      80
      443
      53 # Adguard DNS
    ];
    allowedUDPPorts = [ 
      443 # pour Cloudflare et HTTP3
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
  fileSystems."/proc" = {
    device = "proc";
    fsType = "proc";
    options = [ "nosuid" "nodev" "noexec" "hidepid=2" ];
  };

  fileSystems."/" = {
    options = [ "defaults" "usrquota" ];
  };

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
  ];
}