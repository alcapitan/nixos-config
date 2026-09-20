{ config, pkgs, pkgs-unstable, ... }:

{
  # * configuration plasma (mis à jour à l'extinction système) : cat ~/.config/plasma-org.kde.plasma.desktop-appletsrc
  # * documentation : https://nix-community.github.io/plasma-manager/options.html
  # * extrait la configuration actuelle : nix run github:nix-community/plasma-manager/trunk#rc2nix

  programs.plasma = {
    enable = true; # ! obligatoire car conditionne les instructions suivantes
    overrideConfig = true; #! destructive
  };

  # Powerdevil est le daemon batterie propre à Plasma, chaque bureau a le sien
  programs.plasma.powerdevil = {
    # Branché sur prise électrique
    AC = {
      dimDisplay.idleTimeout = 600;
      turnOffDisplay.idleTimeout = 900;
      inhibitLidActionWhenExternalMonitorConnected = false;
      powerButtonAction = "sleep";
    };

    battery = {
      dimDisplay.idleTimeout = 600;
      turnOffDisplay.idleTimeout = 900;
      inhibitLidActionWhenExternalMonitorConnected = false;
      powerButtonAction = "sleep";
    };

    lowBattery = {
      displayBrightness = 10;
      keyboardBrightness = 0;
      inhibitLidActionWhenExternalMonitorConnected = false;
      powerButtonAction = "sleep";
      whenSleepingEnter = "hybridSleep";
    };
  };

  programs.plasma.kwin = {
    titlebarButtons.left = [
      "keep-above-windows"
    ];

    nightLight = {
      enable = true;
      mode = "times";
      time = {
        evening = "20:00";
        morning = "07:00";
      };
    };
  };

  programs.plasma.input.keyboard = {
    numlockOnStartup = "on";
  };

  programs.plasma.krunner = {
    position = "center";
  };

  programs.plasma.hotkeys.commands = {
    "open-gemini" = {
      name = "Ouvrir Gemini";
      key = "Ctrl+Alt+G";
      command = "xdg-open https://gemini.google.com";
    };
  };

  programs.plasma.workspace = {
    colorScheme = "BreezeDark";
    theme = "breeze-dark";
    lookAndFeel = "org.kde.breezedark.desktop";

    cursor = {
      size = 42;
    };
  };

  programs.plasma.panels = [
    {
      location = "bottom";
      floating = true;
      height = 44;
      widgets = [
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
        "org.kde.plasma.mediacontroller"
        {
          pager = {
            general = {
              # options disponibles :
              # showWindowOutlines = true;
              # showApplicationIconsOnWindowOutlines = false;
              # showOnlyCurrentScreen = false;
              # navigationWrapsAround = false;
              # displayedText = "none"; # ou "desktopNumber", "desktopName"
              # selectingCurrentVirtualDesktop = "showDesktop"; # ou "doNothing"
            };
          };
        }
        { panelSpacer = { expanding = true; }; }
        {
          kickoff = {
            icon = "nix-snowflake-white";
            showButtonsFor = "power";
          };
        }
        {
          iconTasks = {
            launchers = [
              "preferred://filemanager"
              "preferred://browser"
              "applications:dev.zed.Zed.desktop"
              "applications:beepertexts.desktop"
              "applications:Proton Authenticator.desktop"
            ];
          };
        }
        { panelSpacer = { expanding = true; }; }
        "org.kde.plasma.marginsseparator"
        {
          systemTray = {
            items = {
              shown = [
                "org.kde.plasma.battery"
                "org.kde.plasma.notifications"
                "org.kde.plasma.clipboard"
              ];
              extra = [
                "org.kde.plasma.cameraindicator"
                "org.kde.plasma.clipboard"
                "org.kde.plasma.devicenotifier"
                "org.kde.plasma.manage-inputmethod"
                "org.kde.plasma.notifications"
                "org.kde.merkuro.contact.applet"
                "org.kde.kscreen"
                "org.kde.plasma.battery"
                "org.kde.plasma.bluetooth"
                "org.kde.plasma.brightness"
                "org.kde.plasma.keyboardindicator"
                "org.kde.plasma.keyboardlayout"
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.printmanager"
                "org.kde.plasma.volume"
                "org.kde.plasma.weather"
              ];
              hidden = [ ];
              configs = {
                battery.showPercentage = true;
              };
            };
          };
        }
        {
          digitalClock = {
            date = {
              enable = true;
              format = {
                custom = "dddd d MMM";
              };
              position = "belowTime";
            };
            font = {
              family = "Liberation Serif";
              size = 12;
              weight = 500;
              bold = false;
              italic = true;
            };
            timeZone = {
              selected = [
                "America/Guadeloupe"
                "Local"
              ];
            };
            calendar = {
              showWeekNumbers = true;
              plugins = [ "pimevents" ];
            };
          };
        }
        "org.kde.plasma.showdesktop"
      ];
    }
  ];

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

  programs.kate = {
    enable = true;
    editor.brackets.automaticallyAddClosing = false;
    editor.font = {
      family = "Liberation Mono";
      pointSize = 14;
    };
  };

  programs.plasma.desktop.widgets = [
    {
      name = "org.kde.plasma.notes";
      position = {
        horizontal = 50;
        vertical = 50;
      };
      size = {
        width = 400;
        height = 400;
      };
      screen = 0; # Écran cible (0 pour l'écran principal ou "all")
      config = {
        General = {
          # * ls ~/.local/share/plasma_notes/
          noteId = "todolist";
          color = "yellow"; # Couleur du post-it : yellow, white, black, red, green, blue, pink, orange, translucent
          fontSize = 13;
        };
      };
    }
  ];

  programs.plasma.workspace = {
    wallpaper = "/etc/wallpaper.jpg";
    wallpaperFillMode = "preserveAspectFit";
    wallpaperBackground = {
      color = "0,0,0"; # format RGB
    };
  };

  home.packages = with pkgs.kdePackages; [
    kate
    kcharselect
    kcolorchooser
    filelight
    kcalc
    plasma-browser-integration
    kdepim-runtime
    kdepim-addons
    akonadi
    eventviews
    merkuro
    pkgs-unstable.kdePackages.koko
  ];
}
