{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;
let
  enabled = config.homelab.roles.chrome or false;
in
{
  options.homelab.roles.chrome = mkEnableOption "Google Chrome";

  config = mkIf enabled {
    environment.systemPackages = with pkgs; 
    [pkgs.google-chrome];
  };
}

