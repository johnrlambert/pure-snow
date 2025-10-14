{ config, lib, pkgs, ... }:

with lib;

let
  enabled = config.homelab.roles.cockpit or false;
in
{
  options.homelab.roles.cockpit =
    mkEnableOption "Cockpit Telemetry System";

  config = mkIf enabled {
    services.cockpit = {
      enable = true;
      port = 9090;
      openFirewall = true; # If this option doesn't exist in your channel, see note below.
      settings = {
        WebService = {
          AllowUnencrypted = true;
        };
      };
    };
  };
}

