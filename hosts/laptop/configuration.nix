{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./borg.nix
  ];

  networking.hostName = "dell3510";
  system.stateVersion = "25.11";

  # Optimisations Hardware spécifiques au Laptop (Batterie / SSD)
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;
  services.fstrim.enable = true;

  # Bootloader spécifique à cette machine
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;
  
  console.earlySetup = true;
  boot.kernelParams = [ "numlock=on" ];

  # Fonctions spécifiques à l'architecture processeur locale
  nix.settings.system-features = [ "gccarch-x86-64-v3" "benchmark" "kvm" "nixos-test" ];

  # Profil d'école spécifique
  profilScolaire.enable = false;

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

  systemd.tmpfiles.rules = [
    "L+ /etc/nixos - - - - /home/alex/nixos-config"
  ];

  # Rétention / Garbage Collector
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}