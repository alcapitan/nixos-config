{ config, pkgs, ... }:

{
  # Résolveur DNS local
  services.unbound = {
    enable = true;
    settings = {
      remote-control = {
        control-enable = true; # Autorise contrôle du serveur dns sur terminal
        control-use-cert = false; # Contrôle local via socket UNIX (évite la gestion de certificats SSL)
        control-interface = "/run/unbound/unbound.ctl";
      };

      server = {
        # Custom adresses
        local-zone = [ "\"alcapitan.local.\" redirect" ];
        local-data = [ "\"alcapitan.local. IN A 127.1.0.1\"" ];

        # Interdit l'usage du serveur par l'extérieur
        interface = [ "127.0.0.1" "::1" ];
        access-control = [ "127.0.0.0/8 allow" "::1/128 allow" ];

        prefer-ip6 = "yes"; # Tente les requêtes récursives en IPv6 en premier

        # Mémoire cache
        # Allocation mémoire
        msg-cache-size = "128m";     # Cache pour les réponses aux requêtes
        rrset-cache-size = "256m";   # Cache pour les enregistrements de ressources (DNSSEC inclus)
        infra-cache-numhosts = 10000; # Nombre d'hôtes distants dont Unbound suit la latence RTT
        key-cache-size = "64m";      # Cache dédié aux clés de validation DNSSEC
        neg-cache-size = "16m";          # Isole le cache des réponses négatives (NXDOMAIN) pour ne pas polluer msg-cache

        # Gestion durée vie TTL
        cache-min-ttl = 300;         # 5 min min. : évite les requêtes abusives sur les micro-TTL
        cache-max-ttl = 86400;       # 24 h max. : garantit la prise en compte des changements d'IP
        cache-max-negative-ttl = 60; # 1 min max. pour les erreurs (NXDOMAIN) : évite de bloquer longtemps un domaine qui vient d'être créé

        # Rafraîchissement & Résilience
        prefetch = "yes";            # Rafraîchit les requêtes fréquentes avant expiration
        prefetch-key = "yes";        # Préchauffe les clés DNSSEC associées
        serve-expired = "yes";       # Répond avec le vieux cache si le serveur amont tarde à répondre
        serve-expired-ttl = 86400;   # Accepte de servir un cache expiré de 24h max en cas de panne réseau
        serve-expired-client-timeout = 250; # Après 250ms d'attente amont, sert l'expiré (évite les timeouts navigateur)
        serve-expired-reply-ttl = 30;    # Indique au client (TTL=30s) que l'enregistrement servi est temporaire
      };

      # Utilise des résolveurs extérieurs rapides pour les adresses inconnues
      forward-zone = [
        {
          # Intercepte toutes les requêtes
          name = ".";

          forward-addr = [
            # Cloudflare
            "2606:4700:4700::1111" # primaire
            "2606:4700:4700::1001" # secondaire
            "1.1.1.1"              # primaire
            "1.0.0.1"              # secondaire

            # Quad9
            "2620:fe::fe"          # primaire
            "2620:fe::9"           # secondaire
            "9.9.9.9"              # primaire
            "149.112.112.112"      # secondaire
          ];
        }
      ];
    };
  };
  networking.nameservers = [ "::1" "127.0.0.1" ]; # Définit les serveurs DNS de la machine
  networking.networkmanager.dns = "none"; # Empêche NetworkManager d'écraser /etc/resolv.conf lors des connexions Wi-Fi / DHCP
  networking.dhcpcd.enable = false;  # Empêche dhcpcd ou d'autres hooks DHCP d'altérer resolv.conf
  
  # Restauration du cache au démarrage & Sauvegarde du cache à l'arrêt
  systemd.services.unbound = {
    serviceConfig = {
      # Crée automatiquement /var/lib/unbound et /run/unbound avec les bons droits
      StateDirectory = "unbound";
      RuntimeDirectory = "unbound";

      # Restauration du cache dès que le service est prêt
      ExecStartPost = pkgs.writeShellScript "unbound-load-cache" ''
        if [ -s /var/lib/unbound/cache.dump ]; then
          ${config.services.unbound.package}/bin/unbound-control -s /run/unbound/unbound.ctl load_cache < /var/lib/unbound/cache.dump || true
        fi
      '';

      # Sauvegarde du cache avant d'arrêter le processus
      ExecStop = [
        "" # Vide le ExecStop par défaut de systemd
        (pkgs.writeShellScript "unbound-dump-cache" ''
          ${config.services.unbound.package}/bin/unbound-control -s /run/unbound/unbound.ctl dump_cache > /var/lib/unbound/cache.dump || true
          ${config.services.unbound.package}/bin/unbound-control -s /run/unbound/unbound.ctl stop || true
        '')
      ];
    };
  };


  /**
  nix shell nixpkgs#dig

  # Tester la résolution
  dig @::1 google.com AAAA
  dig @127.0.0.1 google.com A
  dig alcapitan.local
  > Regarder query time (temps de réponse)

  # Voir le contenu du cache
  sudo unbound-control -s /run/unbound/unbound.ctl dump_cache | less

  # Voir le contenu de la sauvegarde
  sudo cat /var/lib/unbound/cache.dump
  */
}