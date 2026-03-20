# modules/home/sops/default.nix
{ lib, config, pkgs, ... }:

let
  enabled = config.homelab.sops.enable or false;
in {
  options.homelab.sops.enable = lib.mkEnableOption "Enable sops and tools";

  config = lib.mkIf enabled {
    home.packages = with pkgs; [ sops age ssh-to-age];
  };
}

