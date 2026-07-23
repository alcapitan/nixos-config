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

  services.unbound = {
    enable = true;
    settings = {
      server = {
        local-zone = [ "\"alcapitan.local.\" redirect" ];
        local-data = [
          "\"alcapitan.local. IN A 127.1.0.1\""
        ];

        cache-min-ttl = 3600;          # Garde en mémoire minimum 1h quand c'est possible
        cache-max-ttl = 86400;         # Cache maximum de 24h
        prefetch = true;               # Rafraîchit automatiquement les domaines populaires avant qu'ils n'expirent
        prefetch-key = true;           # Accélère les requêtes DNSSEC
        msg-cache-size = "16m";        # Taille du cache des messages
        rrset-cache-size = "32m";      # Taille du cache des enregistrements
      };

      forward-zone = [
        {
          name = ".";
          forward-addr = [
            "127.1.0.1@5353"
            "1.1.1.1@853#cloudflare-dns.com"
            "1.0.0.1@853#cloudflare-dns.com"
          ];
          forward-first = true;
        }
      ];
    };
  };
  networking.nameservers = [ "127.0.0.1" ]; #! attention un wifi restreignant fermement les ports peut bloquer le dns, donc commenter cette ligne si besoin
}