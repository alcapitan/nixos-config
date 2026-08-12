{ config, pkgs, ... }:

{
  sops.age.keyFile = "/var/lib/secrets/sops-key.txt";

  sops.secrets = {
    "home/ssid" = { sopsFile = ./wifi_credentials.yaml; };
    "home/password" = { sopsFile = ./wifi_credentials.yaml; };
    "phone_hotspot/ssid" = { sopsFile = ./wifi_credentials.yaml; };
    "phone_hotspot/password" = { sopsFile = ./wifi_credentials.yaml; };
    "gene/ssid" = { sopsFile = ./wifi_credentials.yaml; };
    "gene/password" = { sopsFile = ./wifi_credentials.yaml; };
    "univ/ssid" = { sopsFile = ./wifi_credentials.yaml; };
    "univ/identity" = { sopsFile = ./wifi_credentials.yaml; };
    "univ/password" = { sopsFile = ./wifi_credentials.yaml; };
  };

  sops.templates."wifi.env".content = ''
    HOME_SSID=${config.sops.placeholder."home/ssid"}
    HOME_PASSWORD=${config.sops.placeholder."home/password"}
    PHONE_SSID=${config.sops.placeholder."phone_hotspot/ssid"}
    PHONE_PASSWORD=${config.sops.placeholder."phone_hotspot/password"}
    GENE_SSID=${config.sops.placeholder."gene/ssid"}
    GENE_PASSWORD=${config.sops.placeholder."gene/password"}
    UNIV_SSID=${config.sops.placeholder."univ/ssid"}
    UNIV_IDENTITY=${config.sops.placeholder."univ/identity"}
    UNIV_PASSWORD=${config.sops.placeholder."univ/password"}
  '';

  networking.networkmanager = {
    enable = true;
    ensureProfiles = {
      environmentFiles = [
        config.sops.templates."wifi.env".path
      ];
      profiles = {
        "home" = {
          connection = {
            id = "Maison";
            type = "wifi";
            autoconnect = true;
          };
          wifi = {
            mode = "infrastructure";
            ssid = "$HOME_SSID";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$HOME_PASSWORD";
          };
        };

        "hotspot" = {
          connection = {
            id = "Partage de connexion";
            type = "wifi";
            autoconnect = true;
          };
          wifi = {
            mode = "infrastructure";
            ssid = "$PHONE_SSID";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$PHONE_PASSWORD";
          };
        };

        "gene" = {
          connection = {
            id = "Gene";
            type = "wifi";
            autoconnect = true;
          };
          wifi = {
            mode = "infrastructure";
            ssid = "$GENE_SSID";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$GENE_PASSWORD";
          };
        };

        "univ" = {
          connection = {
            id = "Univ";
            type = "wifi";
            autoconnect = true;
          };
          wifi = {
            mode = "infrastructure";
            ssid = "$UNIV_SSID";
          };
          wifi-security = {
            key-mgmt = "wpa-eap";
          };
          "802-1x" = {
            eap = "ttls;";
            phase2-auth = "pap";
            anonymous-identity = "anonymous@univ-avignon.fr";
            identity = "$UNIV_IDENTITY";
            password = "$UNIV_PASSWORD";
          };
        };
      };
    };
  };

  # TODO: dupliquer des connexions pour utiliser dns/vpn spécifique
  # TODO: documenter comment j'ai extrait les profils network-manager
}