{ ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/srv/forgejo/data 0755 1082 1082 -" # uid de git dans forjego
  ];

  virtualisation.oci-containers.containers.forgejo = {
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

  services.caddy.virtualHosts."git.alcapitan.me".extraConfig = "reverse_proxy 127.0.0.1:8082";
}
