{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;
let
  enabled = config.homelab.roles.cockpit or false;
in
{
  options.homelab.roles.cockpit = mkEnableOption "Cockpit telemetry system";

  config = mkIf enabled {
    environment.systemPackages = with pkgs; 
    [pkgs.cockpit];
  };
}
