{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;
let
  enabled = config.homelab.roles.snowfall or false;
in
{
  options.homelab.roles.snowfall = mkEnableOption "Snowfall Cockpit Telemetry System";

  config = mkIf enabled {
    environment.systemPackages = with pkgs; 
    [pkgs.snowfall-cockpit-telemetry];
  };
}
