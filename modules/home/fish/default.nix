# modules/home/fish/default.nix
{ config, pkgs, lib, ... }:

lib.mkIf config.homelab.fish.enable {
  home.packages = with pkgs; [ fish eza bat ];

  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "eza -la";
      cat = "bat";
    };
  };
}

