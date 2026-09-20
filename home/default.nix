{ pkgs, ... }:

{
  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "25.11";

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Configuration du Shell commun
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true; # vert si binaire reconnu, rouge si inexistant
  };

  # Configuration de Git
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Al Capitan";
        email = "alexandre.boyer29@gmail.com";
      };
    };
    signing = {
      key = "17301109DA7684605B5820CD4CA4D08247638EA0";
      signByDefault = true;
    };
  };
  programs.delta = { # Meilleur diff pour git
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true; # Permet de sauter de fichier en fichier avec 'n' et 'N'
      line-numbers = true;
      side-by-side = true; # Vue côte à côte
    };
  };

  # Accès SSH commun vers le stockage Borg
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "Host borg-repo" = {
        HostName = "u502181-sub4.your-storagebox.de";
        User = "u502181-sub4";
        Port = "23";
      };
      "Host ssh.alcapitan.me alcap" = {
        ProxyCommand = "cloudflared access ssh --hostname ssh.alcapitan.me";
        User = "alex";
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  # message d'avertissement dans le shell interactif d'utilisation de commandes remplacés
  programs.zsh.initContent = ''
    if [ -t 1 ]; then
      # Supprime les alias préexistants pour éviter le conflit avec les fonctions
      unalias ls 2>/dev/null

      _warn_tool() {
        local old_cmd="$1"
        local new_cmd="$2"
        shift 2
        printf "\033[33m[Conseil]\033[0m Utilise '%s' au lieu de '%s'.\n" "$new_cmd" "$old_cmd" >&2
        command "$old_cmd" "$@"
      }

      function top { _warn_tool top btop "$@"; }
      function htop { _warn_tool htop btop "$@"; }
      function find { _warn_tool find fd "$@"; }
      function grep { _warn_tool grep rg "$@"; }
      function sed { _warn_tool sed sd "$@"; }
      function cat { _warn_tool cat bat "$@"; }
      function ls { _warn_tool ls eza "$@"; }
      function df { _warn_tool df duf "$@"; }
      function du { _warn_tool du dust "$@"; }
      function diff { _warn_tool diff delta "$@"; }
      function ps { _warn_tool ps procs "$@"; }
      function man { _warn_tool man "tldr (tealdeer)" "$@"; }
      function ping { _warn_tool ping gping "$@"; }
      function time { _warn_tool time hyperfine "$@"; }
      function nixos-rebuild { _warn_tool nixos-rebuild nh "$@"; }

      # Cas particulier du builtin cd
      cd() {
        if [ "$#" -gt 0 ]; then
          printf "\033[33m[Conseil]\033[0m Pense à utiliser 'z' au lieu de 'cd'.\n" >&2
        fi
        builtin cd "$@"
      }
    fi
  '';

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {};
  };

  home.shellAliases = {
    nix-switch = "nh os switch /home/alex/nixos-config -H dell3510";
    nix-test   = "nh os test /home/alex/nixos-config -H dell3510";
    nix-dry    = "nh os switch /home/alex/nixos-config -H dell3510 --dry";
    nix-boot   = "nh os boot /home/alex/nixos-config -H dell3510";
    nix-update = "nh os switch /home/alex/nixos-config -H dell3510 --update";
    nix-audit  = "vulnix --system --show-description";
    nix-size   = "nix build /home/alex/nixos-config#nixosConfigurations.dell3510.config.system.build.toplevel --dry-run";
  };
}
