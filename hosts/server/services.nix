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

      vaultwarden = {
        image = "vaultwarden/server:latest";
        ports = [
          "127.0.0.1:8086:80"
        ];
        volumes = [
          "/var/lib/srv/vaultwarden/data:/data"
        ];
        environment = {
          "DOMAIN" = "https://vault.alcapitan.me";
          "SIGNUPS_ALLOWED" = "true"; # à repasser à "false" une fois ton compte créé
        };
        extraOptions = [ "--pull=always" ];
      };

      # --- Immich Database ---
      immich-postgres = {
        image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23";
        volumes = [
          "/var/lib/srv/immich/postgres:/var/lib/postgresql/data"
        ];
        environment = {
          "POSTGRES_USER" = "postgres";
          "POSTGRES_PASSWORD" = "zDCwXjIzO578XPMz--lBlr2e";
          "POSTGRES_DB" = "immich";
          "POSTGRES_INITDB_ARGS" = "--data-checksums";
          "DB_STORAGE_TYPE" = "SSD";
        };
        extraOptions = [
          "--pull=always"
          "--shm-size=128m" # Équivalent de shm_size: 128mb
        ];
      };

      # --- Immich Redis (Valkey) ---
      immich-redis = {
        image = "docker.io/valkey/valkey:9@sha256:4963247afc4cd33c7d3b2d2816b9f7f8eeebab148d29056c2ca4d7cbc966f2d9";
        extraOptions = [ "--pull=always" ];
      };

      # --- Immich Server ---
      immich-server = {
        image = "ghcr.io/immich-app/immich-server:v3";
        ports = [
          "127.0.0.1:8087:2283"
        ];
        volumes = [
          "/var/lib/srv/immich/library:/data"
          "/etc/localtime:/etc/localtime:ro"
        ];
        environment = {
          "TZ" = "Europe/Paris";
          "DB_HOSTNAME" = "immich-postgres";
          "DB_USERNAME" = "postgres";
          "DB_PASSWORD" = "zDCwXjIzO578XPMz--lBlr2e";
          "DB_DATABASE_NAME" = "immich";
          "REDIS_HOSTNAME" = "immich-redis";
          "IMMICH_MACHINE_LEARNING_ENABLED" = "false";
        };
        dependsOn = [ "immich-postgres" "immich-redis" ];
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
      "vault.alcapitan.me".extraConfig = "reverse_proxy 127.0.0.1:8086";
      "pics.alcapitan.me".extraConfig = ''
        reverse_proxy 127.0.0.1:8087 {
          transport http {
            read_buffer 8192
          }
        }
        # Permet l'upload de gros fichiers photos/vidéos sans troncature
        request_body {
          max_size 1GB
        }
      '';
    };
  };

  # Surcharge caddy pour l'environnement de test en machine virtuelle
  virtualisation.vmVariant = {
    services.caddy = {
      globalConfig = ''
        auto_https disable_redirects
      '';

      # Réécriture des virtualHosts pour le développement local
      virtualHosts = pkgs.lib.mkForce {
        "http://alcapitan.local".extraConfig = "reverse_proxy 127.0.0.1:8081";
        "http://git.alcapitan.local".extraConfig = "reverse_proxy 127.0.0.1:8082";
        "http://initial.dns.alcapitan.local".extraConfig = "reverse_proxy 127.0.0.1:8083";
        "http://dns.alcapitan.local".extraConfig = "reverse_proxy 127.0.0.1:8084";
        "http://dav.alcapitan.local".extraConfig = "reverse_proxy 127.0.0.1:8085";
        "https://vault.alcapitan.local".extraConfig = ''
          tls internal
          reverse_proxy 127.0.0.1:8086
        ''; # parce que HTTPS obligatoire
        #* certificat HTTPS autosigné Caddy: /var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt
        "http://pics.alcapitan.local".extraConfig = ''
          reverse_proxy 127.0.0.1:8087
          request_body {
            max_size 1GB
          }
        '';
      };
    };
  };
}
