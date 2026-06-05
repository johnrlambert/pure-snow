{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;
let
  enabled = hasRole "chrome" config.homelab.roles;
in
{
  options.homelab.roles.chrome = mkEnableOption "Google Chrome";

  config = mkIf enabled {
    environment.systemPackages = with pkgs; 
    [pkgs.google-chrome];
  };
}

