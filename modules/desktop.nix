{ config, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./scolaire.nix
    ./gaming.nix
    ./sway.nix
    ./banner.nix
  ];

  options.services.vpsMount.enable = lib.mkEnableOption "Active le montage SSHFS automatique du serveur sur /home/alex/vps via Cloudflared";

  config = lib.mkMerge [
    {
      # Réseau et Bluetooth
      systemd.network.wait-online.enable = true; # network-online.target de systemd sera validé quand la connexion sera vraiment effective
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
      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
        config = {
          common = {
            default = [ "kde" ];
          };
        };
      };

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
      virtualisation.libvirtd = {
        enable = true;
        onBoot = "ignore"; # pour accélérer le démarrage
      };

      environment.systemPackages = with pkgs; [
        virt-manager
        gparted
        e2fsprogs # pour lsattr et chattr ; pour une gestion des droits avancée
        sbctl
        pinentry-qt
        kdePackages.bluedevil # bluetui
        pkgs-unstable.proton-vpn
        android-tools # pour le transfert de fichiers avec adb + l'exécution android pour programmation
        wl-clipboard
        pkgs-unstable.ventoy-full-qt
        docker
        pkgs.sshfs
        pkgs-unstable.cloudflared
        hunspell # correcteur linguistique
        hunspellDicts.fr-moderne
      ];
      environment.plasma6.excludePackages = with pkgs.kdePackages; [
        discover
      ];

      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        pinentryPackage = pkgs.pinentry-qt;
      };

      programs.localsend = {
        enable = true;
        openFirewall = true;
        package = pkgs-unstable.localsend;
      };

      environment.etc."wallpaper.jpg".source = ../assets/wallpaper.jpg;

      virtualisation.docker.enable = true;
      users.users.alex.extraGroups = [ "networkmanager" "libvirtd" "docker" "kvm" "adbusers" ];

      programs.fuse.userAllowOther = true;
    }

    (lib.mkIf config.services.vpsMount.enable {
      systemd.tmpfiles.rules = [
        "d /home/alex/vps 0755 alex users -"
      ];

      fileSystems."/home/alex/vps" = {
        device = "alex@ssh.alcapitan.me:/home/alex";
        fsType = "fuse.sshfs";
        options = [
          "noauto"
          "x-systemd.automount"
          "x-systemd.idle-timeout=10min"
          "_netdev"
          "allow_other"
          "uid=1000"
          "gid=100"
          "reconnect"
          "ServerAliveInterval=15"
          "ServerAliveCountMax=3"
          "IdentityFile=/home/alex/.ssh/id_ed25519"
          "ProxyCommand=${pkgs-unstable.cloudflared}/bin/cloudflared access ssh --hostname ssh.alcapitan.me"
          "StrictHostKeyChecking=accept-new"
        ];
      };
    })
  ];
}
