{ ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/srv/immich/library 0755 root root -"
    "d /var/lib/srv/immich/postgres 0700 999 999 -" # uid de postgres dans l'image
  ];

  virtualisation.oci-containers.containers = {
    # --- Immich Database ---
    immich-postgres = {
      image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23";
      volumes = [
        "/var/lib/srv/immich/postgres:/var/lib/postgresql/data"
      ];
      environment = {
        "POSTGRES_USER" = "postgres";
        "POSTGRES_PASSWORD" = "zDCwXjIzO578XPMz--lBlr2e"; # TODO: publié en clair, à modifier et à rentrer dans sops
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

  services.caddy.virtualHosts."pics.alcapitan.me".extraConfig = ''
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
}
