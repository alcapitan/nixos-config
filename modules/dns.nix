{ config, ... }:

{
  # Résolveur DNS local
  services.unbound = {
    enable = true;
    settings = {
      remote-control.control-enable = true;

      server = {
        local-zone = [ "\"alcapitan.local.\" redirect" ];
        local-data = [ "\"alcapitan.local. IN A 127.1.0.1\"" ];

        /* # TODO: fix dns
        # Prevent IPv6 timeouts if IPv6 isn't fully routed locally
        ip-ipv6 = false; # Set to true ONLY if you have working native IPv6

        # Optimizations for DoT connection reuse & faster handling
        delay-close = 10000;
        target-fetch-policy = "1 1 1 1 1";

        # Fix the serve-expired timeout (Value is in MILLISECONDS)
        serve-expired = true;
        serve-expired-reply-ttl = 30;
        serve-expired-ttl = 259200;
        serve-expired-client-timeout = 250; # 250ms max wait before serving expired / proceeding

        # Existing caches
        cache-min-ttl = 14400;
        cache-max-ttl = 604800;
        prefetch = true;
        prefetch-key = true;
        msg-cache-size = "128m";
        rrset-cache-size = "256m";
        key-cache-size = "64m";
        neg-cache-size = "16m";
        infra-cache-numhosts = 10000;
        cache-max-negative-ttl = 3600;
        */
      };

      /* forward-zone = [
        {
          name = ".";
          forward-tls-upstream = true; # Explicitly inform Unbound to use TLS for this zone
          forward-addr = [
            "1.1.1.1@853#cloudflare-dns.com"
            "1.0.0.1@853#cloudflare-dns.com"
          ];
          forward-first = false; # Set to false if you strictly want Cloudflare over TLS
        }
      ];*/
    };
  };
  # networking.nameservers = [ "127.0.0.1" ]; #! attention un wifi restreignant fermement les ports peut bloquer le dns, donc commenter cette ligne si besoin

  /*
  # Activer le fichier de sauvegarde du cache
  systemd.services.unbound-cache-persistence = {
    description = "Sauvegarde et Restauration du cache Unbound";
    wantedBy = [ "multi-user.target" ];
    before = [ "unbound.service" ];
    after = [ "network.target" ];
    requires = [ "unbound.service" ];
    script = ''
      # Ce script charge le cache s'il existe au démarrage
      if [ -f /var/lib/unbound/dump.cache ]; then
        ${config.services.unbound.package}/bin/unbound-control load_cache < /var/lib/unbound/dump.cache || true
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = ''
        ${config.services.unbound.package}/bin/unbound-control dump_cache > /var/lib/unbound/dump.cache || true
      '';
    };
  };
  */
}