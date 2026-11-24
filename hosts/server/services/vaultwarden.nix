{ ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/srv/vaultwarden/data 0755 root root -"
  ];

  virtualisation.oci-containers.containers.vaultwarden = {
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

  services.caddy.virtualHosts."vault.alcapitan.me".extraConfig = "reverse_proxy 127.0.0.1:8086";
}
