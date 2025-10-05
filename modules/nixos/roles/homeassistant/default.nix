{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;
let
  enabled = config.homelab.roles.chrome or false;
in
{
  options.homelab.roles.chrome = mkEnableOption "Home Assistant";

  config = mkIf enabled {
  	services.home-assistant = {
    	enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "esphome"
      "met"
      "radio_browser"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};
    };
  };
  };
}

