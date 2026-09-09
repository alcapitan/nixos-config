{ config, pkgs, pkgs-unstable, ... }:

{
    home.packages = with pkgs; [
        kdePackages.kate
        kdePackages.kcharselect
        kdePackages.kcolorchooser
        kdePackages.filelight
        kdePackages.kcalc
        kdePackages.plasma-browser-integration
        kdePackages.kdepim-runtime
        kdePackages.kdepim-addons
        kdePackages.merkuro
        pkgs-unstable.kdePackages.koko
    ];

    # Raccourci Web personnalisé
    xdg.desktopEntries = {
        open-gemini = {
            name = "Ouvrir Gemini";
            exec = "xdg-open https://gemini.google.com";
            icon = "internet-web-browser";
            settings = {
                X-KDE-Shortcuts = "Ctrl+Alt+G";
            };
        };
    };

    # Configuration du Terminal Konsole
    programs.konsole = {
        enable = true;
        defaultProfile = "MonProfil";
        profiles = {
            "MonProfil" = {
                name = "MonProfil";
                font = {
                    name = "Liberation Mono";
                    size = 14;
                };
            };
        };
    };

    # Configuration de l'éditeur Kate
    programs.kate = {
        enable = true;
        editor.brackets.automaticallyAddClosing = false;
        editor.font = {
            family = "Liberation Mono";
            pointSize = 14;
        };
    };

    # TODO: réparer ce bordel (options inexistantes)
    #* extrait la configuration actuelle : nix run github:nix-community/plasma-manager/trunk#rc2nix
    /*
    # Configuration spécifique à Plasma (Fond d'écran...)
    programs.plasma = {
        enable = true;
        # overrideConfig = true; #! destructive

        workspace.wallpaper = "/etc/wallpaper.jpg";

        input.keyboard.numlockOnStartup = "on";

        krunner = {
        position = "center";
        };

        # colorScheme = "BreezeDark";
        windowManager.kwin.titlebar = {
        # Disposition classique KDE (Réduire, Agrandir, Fermer à droite)
        buttons = {
            right = [ "minimize" "maximize" "close" ];
            left = [ "above_all" ];
        };
        };

        panels = [
        # =================================================================
        # Panneau 1 : Écran Principal (screen 0)
        # =================================================================
        {
            location = "bottom";
            screen = 0;
            widgets = [
            # 1. Widget Météo (Configuré sur Avignon)
            {
                name = "org.kde.plasma.weather";
                config = {
                WeatherStation = {
                    placeDisplayName = "Avignon, France, FR";
                    placeInfo = "Avignon, France, FR|3035681";
                    provider = "bbcukmet";
                };
                };
            }

            # 2. Contrôleur Média
            "org.kde.plasma.mediacontroller"

            # 3. Pager (Changeur de bureaux virtuels)
            "org.kde.plasma.pager"

            # 4. Espaceur
            "org.kde.plasma.panelspacer"

            # 5. Menu Démarrer (Kickoff avec l'icône Nix)
            {
                name = "org.kde.plasma.kickoff";
                config = {
                General = {
                    icon = "nix-snowflake-white";
                    systemFavorites = "suspend\\,hibernate\\,reboot\\,shutdown";
                };
                };
            }

            # 6. Gestionnaire de tâches (Icônes seules)
            "org.kde.plasma.icontasks"

            # 7. Espaceur
            "org.kde.plasma.panelspacer"

            # 8. Séparateur de marges
            "org.kde.plasma.marginsseparator"

            # 9. Boîte à miniatures (System Tray)
            {
                name = "org.kde.plasma.systemtray";
                config = {
                General = {
                    shownItems = [
                    "org.kde.plasma.battery"
                    "org.kde.plasma.notifications"
                    "org.kde.plasma.clipboard"
                    ];
                };
                };
            }

            # 10. Horloge digitale (Configurée avec la Guadeloupe & Numéros de semaine)
            {
                name = "org.kde.plasma.digitalclock";
                config = {
                Appearance = {
                    enabledCalendarPlugins = "pimevents";
                    fontWeight = 400;
                    selectedTimeZones = [ "America/Guadeloupe" "Local" ];
                    showWeekNumbers = true;
                };
                };
            }

            # 11. Afficher le bureau
            "org.kde.plasma.showdesktop"
            ];
        }
        ];
    };
    */
}
