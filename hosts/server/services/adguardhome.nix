{ ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/srv/adguardhome/work 0755 root root -"
    "d /var/lib/srv/adguardhome/conf 0755 root root -"
  ];

  virtualisation.oci-containers.containers.adguardhome = {
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

  services.caddy.virtualHosts = {
    "initial.dns.alcapitan.me".extraConfig = "reverse_proxy 127.0.0.1:8083";
    "dns.alcapitan.me".extraConfig = "reverse_proxy 127.0.0.1:8084";
  };
}
