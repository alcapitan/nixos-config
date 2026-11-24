{ pkgs, ... }:

{
  imports = [
    ./portfolio.nix
    ./forgejo.nix
    ./adguardhome.nix
    ./radicale.nix
    ./vaultwarden.nix
    ./immich.nix
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Permet d'utiliser la commande 'docker' si besoin
    defaultNetwork.settings.dns_enabled = true; # Permet communication entre containers en s'appelant par leurs noms plutôt que par des IP locales non-fixes
  };

  # Conteneur (comme docker mais rootless)
  virtualisation.oci-containers.backend = "podman";
  # TODO: il faudrait voir de migrer la data des services vers la storage box...

  # Reverse proxy pour production
  services.caddy.enable = true;

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
