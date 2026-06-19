{ config, pkgs, ... }:

{
    imports = [
        ./hardware-configuration.nix
        ./scolaire.nix
        ./borg.nix
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.settings.system-features = [ "gccarch-x86-64-v3" "benchmark" "kvm" "nixos-test" ];
    nix.channel.enable = false;

    networking.hostName = "dell3510";

    networking.networkmanager.enable = true;

    time.timeZone = "Europe/Paris";
    i18n.defaultLocale = "fr_FR.UTF-8";
    console.keyMap = "fr";
    services.xserver = {
        enable = true;
        xkb = {
            layout = "fr";
            variant = "azerty";
        };
    };

    boot.loader.grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
    };
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelPackages = pkgs.linuxPackages_zen;
    services.ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
    };

    console.earlySetup = true;
    boot.kernelParams = [ "numlock=on" ];
    #services.displayManager.sddm.autoNumlock = true;
    #services.xserver.displayManager.setupCommands = ''
    #   ${pkgs.numlockx}/bin/numlockx on
    #'';

    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
    security.polkit.enable = true;
    services.displayManager.sddm.autoNumlock = true;

    services.power-profiles-daemon.enable = false;
    services.tlp.enable = true;
    services.fstrim.enable = true; # Active le TRIM hebdomadaire pour les SSD

    services.printing.enable = true;

    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
    };
    hardware.bluetooth.enable = true;

    security.sudo.extraConfig = ''
        Defaults env_reset,pwfeedback
    '';

    fileSystems."/home/alex/tmp" = {
        fsType = "tmpfs";
        device = "tmpfs";
        options = [
            "size=4G"
            "mode=750"
            "uid=1000"
        ];
    };

    systemd.tmpfiles.rules = [
        "L+ /etc/nixos - - - - /home/alex/nixos-config"
    ];

    virtualisation.libvirtd.enable = true;

    profilScolaire.enable = false;

    nix.settings.auto-optimise-store = true;
    nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
    };

    programs.zsh = {
        enable = true;
        interactiveShellInit = ''
          eval "$(direnv hook zsh)"
        '';
    };

    users.users.alex = {
        isNormalUser = true;
        description = "Al Capitan";
        extraGroups = [ "networkmanager" "wheel" "libvirtd" "adbusers" ];
	    shell = pkgs.zsh;

        packages = with pkgs; [
            firefox
            thunderbird
            libreoffice-qt-fresh
            vlc
            kdePackages.kate
            kdePackages.kcharselect
            kdePackages.kcolorchooser
            kdePackages.merkuro
            kdePackages.filelight
            kdePackages.kcalc
            kdePackages.plasma-browser-integration
            brave
            vscode
            # flutter
            beeper
            proton-vpn
            discord
            inkscape
            gimp
            yt-dlp
            parabolic
            tagger
            proton-authenticator
        ];
    };

    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
        git
        vim
        curl
        wget
        bash
        direnv
        nix-direnv
        virt-manager
        fastfetch
        btop
        borgbackup
        gparted
        ntfs3g
        gnupg
        # docker
        android-studio
        pinentry-qt
        kdePackages.bluedevil
        zip
        unzip
        pdftk
        imagemagick
        android-tools
        _7zip-zstd
    ];

    environment.shellAliases = {
        nix-switch = "sudo nixos-rebuild switch --flake /home/alex/nixos-config#dell3510";
        nix-test = "sudo nixos-rebuild test --flake /home/alex/nixos-config#dell3510";
        nix-dry = "sudo nixos-rebuild dry-activate --flake /home/alex/nixos-config#dell3510";
        nix-boot = "sudo nixos-rebuild boot --flake /home/alex/nixos-config#dell3510";
        nix-update = "nix flake update --flake /home/alex/nixos-config && sudo nixos-rebuild switch --flake /home/alex/nixos-config#dell3510";
    };

    programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        pinentryPackage = pkgs.pinentry-qt;
    };

    programs.localsend = {
        enable = true;
        openFirewall = true;
    };

    system.stateVersion = "25.11";
}
