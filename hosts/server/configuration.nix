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

      forwardPorts = [
        { from = "host"; host.address = "127.1.0.1"; host.port = 8000; guest.port = 80; }
        { from = "host"; host.address = "127.1.0.1"; host.port = 2222; guest.port = 2222; }
      ];
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 
      2222
      80
      443
    ];
    allowedUDPPorts = [ 
      443 # pour Cloudflare et HTTP3
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
}