{ pkgs, lib, config, ... }:
with lib;
with lib.homelab;

{
  imports = [ ./hardware.nix ];
 # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "IvyMike";
  system.stateVersion = "25.11";

  homelab.roles.chrome = true;
  homelab.roles.fish = true;
  homelab.roles.desktop.pantheon = true;
  homelab.roles.ssh = true;

  users.mutableUsers = true;

  users.users.john = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINN9vMs23mK242aEaHuwwTqcVoABjY4f82PicdnnnFqy john@wef"
    ];
  };

  # System-wide fish config (optional but common)
  programs.fish.enable = true;
}

