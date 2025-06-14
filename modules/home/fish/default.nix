# modules/home/fish/default.nix
{ lib, config, pkgs, ... }:

let
  enabled = config.homelab.fish.enable or false;
in {
  options.homelab.fish.enable = lib.mkEnableOption "Enable fish shell and tools";

  config = lib.mkIf enabled {
    home.packages = with pkgs; [ fish eza bat ];
  };
}

