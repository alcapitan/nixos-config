{ pkgs, config, ... }:

{
    environment.systemPackages = [ pkgs.cifs-utils ];

    systemd.tmpfiles.rules = [
        "d /mnt/storagebox 0755 root root -"
    ];

    sops.secrets."storagebox/username" = {
        sopsFile = ./credentials.yaml;
    };
    sops.secrets."storagebox/password" = {
        sopsFile = ./credentials.yaml;
    };

    sops.templates."storagebox-credentials" = {
        content = ''
        username=${config.sops.placeholder."storagebox/username"}
        password=${config.sops.placeholder."storagebox/password"}
        '';
        path = "/var/lib/secrets/storagebox";
        owner = "root";
        group = "root";
        mode = "0400";
    };
}