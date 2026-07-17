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
    };
  };

  # Reverse proxy (avec HTTPS automatique)
  services.caddy = {
    enable = true;
    
    virtualHosts = {
      "alcapitan.local, www.alcapitan.me" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8081
        '';
      };

      "http://git.alcapitan.local, http://git.alcapitan.me" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8082
        '';
      };
    };
  };
}