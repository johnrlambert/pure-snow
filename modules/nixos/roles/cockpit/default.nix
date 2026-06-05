{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;

let
  enabled = hasRole "cockpit" config.homelab.roles;
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

