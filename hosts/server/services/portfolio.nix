{ ... }:

{
  virtualisation.oci-containers.containers.portfolio = {
    image = "ghcr.io/alcapitan/portfolio:latest";
    ports = [ "127.0.0.1:8081:80" ];
    extraOptions = [ "--pull=always" ]; # Met à jour à chaque redémarrage
  };

  services.caddy.virtualHosts."alcapitan.me".extraConfig = "reverse_proxy 127.0.0.1:8081";
}
