# modules/home/sops/default.nix
{ lib, config, pkgs, ... }:

let
  enabled = config.homelab.fish.enable or false;
in {
  options.homelab.fish.enable = lib.mkEnableOption "Enable sops and tools";

  config = lib.mkIf enabled {
    home.packages = with pkgs; [ sops age ssh-to-age];
  };
}

