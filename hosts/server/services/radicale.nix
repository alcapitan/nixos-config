{ ... }:

let
  radicaleConfig = builtins.toFile "radicale.conf" ''
    [server]
    hosts = 0.0.0.0:5232

    [storage]
    type = multifilesystem
    filesystem_folder = /data/collections

    [auth]
    type = htpasswd
    htpasswd_filename = /config/users
    htpasswd_encryption = bcrypt
  '';
in
{
  systemd.tmpfiles.rules = [
    "d /var/lib/srv/radicale/data 0770 2999 2999 -" # radicale user uid
    "d /var/lib/srv/radicale/config 0755 root root -"
    "L+ /var/lib/srv/radicale/config/config - - - - ${radicaleConfig}"
  ];

  virtualisation.oci-containers.containers.radicale = {
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

  services.caddy.virtualHosts."dav.alcapitan.me".extraConfig = "reverse_proxy 127.0.0.1:8085";
}
