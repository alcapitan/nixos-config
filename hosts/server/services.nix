{ pkgs, ... }:

{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Permet d'utiliser la commande 'docker' si besoin
    defaultNetwork.settings.dns_enabled = true; # Permet communication entre containers en s'appelant par leurs noms plutôt que par des IP locales non-fixes
  };

  # Conteneur (comme docker mais rootless)
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      portfolio = {
        image = "ghcr.io/alcapitan/portfolio:latest";
        ports = [ "127.0.0.1:8081:80" ];
        extraOptions = [ "--pull=always" ]; # Met à jour à chaque redémarrage
      };

      forgejo = {
        image = "codeberg.org/forgejo/forgejo:16"; 
        ports = [
          "127.0.0.1:8082:3000" # interface web
          "0.0.0.0:22:22"     # SSH pour les accès Git (git clone / push)
        ];
        volumes = [
          "/var/lib/srv/forgejo/data:/data"
        ];
        environment = {
          "USER_UID" = "1082"; # id de l'user git dans le container forgejo
          "USER_GID" = "1082";
          "FORGEJO__server__ROOT_URL" = "http://git.alcapitan.local/";
          "FORGEJO__server__DOMAIN" = "git.alcapitan.local";
          "FORGEJO__server__SSH_PORT" = "22";
          "FORGEJO__server__SSH_DOMAIN" = "git.alcapitan.local";
          "FORGEJO__DEFAULT__APP_NAME" = "Alcapitan's Forgejo";
        };
        extraOptions = [ "--pull=always" ];
      };

      adguardhome = {
        image = "adguard/adguardhome:latest"; # TODO: version fixe à définir pour chaque service ! et avoir un controleur de version obsolète pour les containers podman
        ports = [
          "53:53/tcp"             # DNS
          "53:53/udp"             # DNS
          "127.0.0.1:8083:3000"   # Interface de configuration initiale
          "127.0.0.1:8084:80"     # Interface d'administration après setup
        ];
        volumes = [
          "/var/lib/srv/adguardhome/work:/opt/adguardhome/work"
          "/var/lib/srv/adguardhome/conf:/opt/adguardhome/conf"
        ];
        extraOptions = [ "--pull=always" ];
      };

      radicale = {
        image = "tomsquest/docker-radicale:latest";
        ports = [
          "127.0.0.1:8085:5232"
        ];
        volumes = [
          "/var/lib/srv/radicale/data:/data"
          "/var/lib/srv/radicale/config:/config:ro"
        ];
        extraOptions = [ "--pull=always" ];
      };
    };
  };
  # TODO: il faudrait voir de migrer la data des services vers la storage box...

  # Reverse proxy pour production
  services.caddy = {
    enable = true;
    
    virtualHosts = {
      "alcapitan.me".extraConfig = "reverse_proxy 127.0.0.1:8081";
      "git.alcapitan.me".extraConfig = "reverse_proxy 127.0.0.1:8082";
      "initial.dns.alcapitan.me".extraConfig = "reverse_proxy 127.0.0.1:8083";
      "dns.alcapitan.me".extraConfig = "reverse_proxy 127.0.0.1:8084";
      "dav.alcapitan.me".extraConfig = "reverse_proxy 127.0.0.1:8085";
    };
  };

  # Surcharge caddy pour l'environnement de test en machine virtuelle
  virtualisation.vmVariant = {
    services.caddy = {
      globalConfig = ''
        auto_https off
      '';
      
      # Réécriture des virtualHosts pour le développement local
      virtualHosts = pkgs.lib.mkForce {
        "http://alcapitan.local".extraConfig = "reverse_proxy 127.0.0.1:8081";
        "http://git.alcapitan.local".extraConfig = "reverse_proxy 127.0.0.1:8082";
        "http://initial.dns.alcapitan.local".extraConfig = "reverse_proxy 127.0.0.1:8083";
        "http://dns.alcapitan.local".extraConfig = "reverse_proxy 127.0.0.1:8084";
        "http://dav.alcapitan.local".extraConfig = "reverse_proxy 127.0.0.1:8085";
      };
    };
  };
}