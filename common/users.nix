{ pkgs, ... }:

{
  users.users.alex = {
    isNormalUser = true;
    description = "Al Capitan";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "adbusers" ];
    shell = pkgs.zsh;
  };
}