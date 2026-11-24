{ config, lib, pkgs, ... }:

with lib;

{
  options.my.thunderbird.enable = mkEnableOption "Active la gestion déclarative des comptes e-mail Thunderbird via Home Manager";

  config = mkIf config.my.thunderbird.enable {
    programs.thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
      };
    };

    accounts.email.accounts = {
      gmail = {
        primary = true;
        address = "alexandre.boyer29@gmail.com";
        userName = "alexandre.boyer29@gmail.com";
        realName = "Alexandre BOYER";
        flavor = "gmail.com"; # Configure automatiquement imap.gmail.com:993 (TLS) et smtp.gmail.com:465 (TLS)
        thunderbird = {
          enable = true;
          profiles = [ "default" ];
        };
      };

      outlook = {
        address = "alexandre.boyer84@outlook.fr";
        userName = "alexandre.boyer84@outlook.fr";
        realName = "Alexandre BOYER";
        # Note: 'flavor = "outlook.office365.com"' met useStartTls=false sur le port SMTP 587 dans HM (bug upstream),
        # on déclare donc explicitement IMAP (993 TLS) et SMTP (587 STARTTLS) sans flavor :
        imap = {
          host = "outlook.office365.com";
          port = 993;
          tls.enable = true;
        };
        smtp = {
          host = "smtp.office365.com";
          port = 587;
          tls = {
            enable = true;
            useStartTls = true;
          };
        };
        thunderbird = {
          enable = true;
          profiles = [ "default" ];
        };
      };
    };
  };
}
