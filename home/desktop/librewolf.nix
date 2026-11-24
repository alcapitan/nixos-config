{ ... }:

{
  programs.librewolf = {
    enable = true;

    languagePacks = [ "fr" ];

    policies = {
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "78272b6fa58f4a1abaac99321d503a20@proton.me" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/proton-pass/latest.xpi";
          installation_mode = "force_installed";
        };
        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };

    settings = {
      "identity.fxaccounts.enabled" = true;
      "intl.locale.requested" = "fr,fr-FR";
      "intl.accept_languages" = "fr-fr,fr,en-us,en";

      "privacy.resistFingerprinting" = false;
      "layers.acceleration.force-enabled" = true;
      "gfx.webrender.all" = true;

      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "privacy.clearOnShutdown.sessions" = false;
      "privacy.sanitize.sanitizeOnShutdown" = false;
      "network.cookie.lifetimePolicy" = 0;
      "privacy.antiTracking.system.profile" = false; # pour conserver les connexions entre sessions

      "cookiebanners.service.mode" = 1; # rejette automatiquement les cookies
      "cookiebanners.service.mode.privateBrowsing" = 1; # rejette également en navigation privée
      "cookiebanners.bannerClicking.enabled" = true;

      "security.webauthn.webauthn_enable_softtoken" = true; # permet extensions pour passkeys
    };
  };
}
