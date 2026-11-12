{ config, pkgs, ... }:

{
  sops.age.keyFile = "/var/lib/secrets/sops-key.txt";

  sops.secrets = {
    "home/ssid" = { sopsFile = ./wifi_credentials.yaml; };
    "home/password" = { sopsFile = ./wifi_credentials.yaml; };
    "phone_hotspot/ssid" = { sopsFile = ./wifi_credentials.yaml; };
    "phone_hotspot/password" = { sopsFile = ./wifi_credentials.yaml; };
    "univ/ssid" = { sopsFile = ./wifi_credentials.yaml; };
    "univ/identity" = { sopsFile = ./wifi_credentials.yaml; };
    "univ/password" = { sopsFile = ./wifi_credentials.yaml; };
    "gene/ssid" = { sopsFile = ./wifi_credentials.yaml; };
    "gene/password" = { sopsFile = ./wifi_credentials.yaml; };
    "mt-andre/ssid" = { sopsFile = ./wifi_credentials.yaml; };
    "mt-andre/password" = { sopsFile = ./wifi_credentials.yaml; };
    "celine/ssid" = { sopsFile = ./wifi_credentials.yaml; };
    "celine/password" = { sopsFile = ./wifi_credentials.yaml; };
  };

  sops.templates."wifi.env".content = ''
    HOME_SSID=${config.sops.placeholder."home/ssid"}
    HOME_PASSWORD=${config.sops.placeholder."home/password"}
    PHONE_SSID=${config.sops.placeholder."phone_hotspot/ssid"}
    PHONE_PASSWORD=${config.sops.placeholder."phone_hotspot/password"}
    UNIV_SSID=${config.sops.placeholder."univ/ssid"}
    UNIV_IDENTITY=${config.sops.placeholder."univ/identity"}
    UNIV_PASSWORD=${config.sops.placeholder."univ/password"}
    GENE_SSID=${config.sops.placeholder."gene/ssid"}
    GENE_PASSWORD=${config.sops.placeholder."gene/password"}
    MTANDRE_SSID=${config.sops.placeholder."mt-andre/ssid"}
    MTANDRE_PASSWORD=${config.sops.placeholder."mt-andre/password"}
    CELINE_SSID=${config.sops.placeholder."celine/ssid"}
    CELINE_PASSWORD=${config.sops.placeholder."celine/password"}
  '';

  networking.networkmanager = {
    enable = true;
    ensureProfiles = {
      environmentFiles = [
        config.sops.templates."wifi.env".path
      ];
      profiles = {
        "ethernet" = {
          connection = {
            id = "Ethernet";
            type = "ethernet";
            interface-name = "eno1";
          };
        };

        "usb" = {
          connection = {
            id = "USB";
            type = "ethernet";
          };
          match = {
            interface-name = "enp0s20f0u[1-3]*";
          };
        };

        "home" = {
          connection = {
            id = "Maison";
            type = "wifi";
          };
          wifi.ssid = "$HOME_SSID";
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$HOME_PASSWORD";
          };
        };

        "hotspot" = {
          connection = {
            id = "Partage de connexion";
            type = "wifi";
          };
          wifi.ssid = "$PHONE_SSID";
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$PHONE_PASSWORD";
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

        "gene" = {
          connection = {
            id = "Gene";
            type = "wifi";
          };
          wifi.ssid = "$GENE_SSID";
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$GENE_PASSWORD";
          };
        };

        "mt-andre" = {
          connection = {
            id = "MT et André";
            type = "wifi";
          };
          wifi.ssid = "$MTANDRE_SSID";
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$MTANDRE_PASSWORD";
          };
        };

        "celine" = {
          connection = {
            id = "Céline";
            type = "wifi";
          };
          wifi.ssid = "$CELINE_SSID";
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$CELINE_PASSWORD";
          };
        };
      };
    };
  };

  # * pour extraire les profils NetworkManager : sudo nix run github:Janik-Haag/nm2nix
}
