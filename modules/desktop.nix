{ pkgs, pkgs-unstable, ... }:

{
  # Réseau et Bluetooth
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;

  # Interface graphique KDE Plasma 6
  services.xserver = {
    enable = true;
    xkb = {
      layout = "fr";
      variant = "azerty";
    };
  };
  services.displayManager.sddm = {
    enable = true;
    autoNumlock = true;
  };
  services.desktopManager.plasma6.enable = true;
  security.polkit.enable = true;

  # Audio (Pipewire)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Services Desktop
  services.printing.enable = true;
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
  };

  # Virtualisation & Outils graphiques système
  virtualisation.libvirtd.enable = true;
  
  environment.systemPackages = with pkgs; [
    virt-manager
    gparted
    ntfs3g
    pinentry-qt
    kdePackages.bluedevil
    pkgs-unstable.proton-vpn
    android-tools
    wl-clipboard
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
  };

  programs.localsend = {
    enable = true;
    openFirewall = true;
  };
}