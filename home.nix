{ config, pkgs, ... }:

{
  home.username = "alex";
  home.homeDirectory = "/home/alex";

  programs.zsh = {
    enable = true;
    
    enableCompletion = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.starship = {
    enable = true;

    settings = {
      # add_newline = false;

      # character = {
      #   success_symbol = "[➜](bold green)";
      #   error_symbol = "[➜](bold red)";
      # };

      # package.disabled = true;
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Al Capitan";
        email = "alexandre.boyer29@gmail.com";
      };
    };
  };

  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;

    matchBlocks = {
      "borg-repo" = {
        hostname = "u502181-sub4.your-storagebox.de";
        user = "u502181-sub4";
        port = 23;
      };
    };
  };

  programs.plasma = {
    enable = true;

    workspace = {
      wallpaper = "/home/alex/Pictures/wallpapers/pont du gard.jpg";
    };

    input.keyboard.numlockOnStartup = "off";
  };

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

  programs.konsole = {
    enable = true;
    defaultProfile = "MonProfil";

    profiles = {
      "MonProfil" = {
        name = "MonProfil";

        font = {
          # Le nom de la police (ex: JetBrainsMono, FiraCode, Hack, etc.)
          name = "JetBrainsMono Nerd Font";

          size = 12;
        };
      };
    };
  };

  programs.kate = {
    enable = true;

    editor.brackets.automaticallyAddClosing = false;

    editor.font = {
      family = "JetBrainsMono Nerd Font";
      pointSize = 12;
    };
  };

  home.stateVersion = "25.11";
}
