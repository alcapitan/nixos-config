{ pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./wifi.nix
  ];

  networking.hostName = "laptop";
  system.stateVersion = "25.11";

  # Optimisations Hardware spécifiques au Laptop (Batterie / SSD)
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;
  services.fstrim.enable = true;

  # Bootloader spécifique à cette machine
  # TODO: créer une seconde partition de boot détachée de Windows pour résoudre les conflits d'overwriting
  boot.loader.systemd-boot = {
    enable = lib.mkForce false;
    # Lanzaboote hérite automatiquement de boot.loader.systemd-boot.extraEntries :
    # extraEntries."debian.conf" = ''
    #   title Debian rescue
    #   efi   /EFI/debian/grubx64.efi
    # '';
  };
  boot.lanzaboote = { # équivalent de systemd-boot avec support secureboot
    enable = true;
    configurationLimit = 10; # Measured boot le limite à 4 démarrables, mais les 10 générations restent accessibles en session ouverte
    pkiBundle = "/var/lib/sbctl";
  };
  boot.initrd.systemd.network.wait-online.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;

  console.earlySetup = true;
  boot.kernelParams = [ "numlock=on" ];

  # Fonctions spécifiques à l'architecture processeur locale
  nix.settings.system-features = [ "gccarch-x86-64-v3" "benchmark" "kvm" "nixos-test" ];

  # Profils thématiques & options système
  profilScolaire.enable = false;
  profilGaming.enable = true;
  profilSway.enable = false;
  boot.customBanner.enable = false;
  services.vpsMount.enable = false;

  # Sauvegarde automatisée BorgBackup
  # TODO: finir de clean les fichiers suivis dont les projets dev old et le scolaire et les jeux (conserver les sauvegardes !!)
  services.myBorg = {
    enable = true;
    repoSubdir = "pc";
    paths = [
      "/home"
      "/var/lib/secrets"
    ];
    extraCreateArgs = "--one-file-system --verbose --stats --exclude-from /home/alex/.borg-exclude "; # --one-file-system empêche de sauvegarder des montages distants
    keepMonthly = 6;
    triggerOnUserLogin = true;
    desktopNotifications = true;
  };

  # Swap pour l'hibernation
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 32 * 1024; # 32Go
    priority = 1;
  } ];

  # Swap ZRAM pour compresser les données en RAM
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    priority = 100;
  };

  # Montage RAM & Liens symboliques propres au laptop
  fileSystems."/home/alex/tmp" = {
    fsType = "tmpfs";
    device = "tmpfs";
    options = [ "size=4G" "mode=750" "uid=1000" ];
  };

  # Rétention / Garbage Collector
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
