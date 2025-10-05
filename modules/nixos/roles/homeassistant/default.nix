{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;
let
  enabled = config.homelab.roles.homeassistant or false;
in
{
  options.homelab.roles.homeassistant = mkEnableOption "Home Assistant";

  config = mkIf enabled {
    services.home-assistant = {
      enable = true;
      extraComponents = [
      	# Base setup (users, UI, recorder, etc.)
    "default_config"

    # Common device/protocol support
    "ssdp"
    "zeroconf"
    "esphome"
    "mqtt"
    "zwave_js"
    "zha"                # Zigbee via zha
    "matter"             # Matter/Thread
    "bluetooth"

    # Media & audio
    "cast"               # Google Cast/Chromecast
    "sonos"
    "spotify"
    "radio_browser"

    # Voice / TTS
    "tts"
    "google_translate"
    "cloud"

    # Energy & sensors
    "energy"
    "mobile_app"         # iOS/Android companion apps
    "met"                # Weather
    "weather"
    "time_date"
    "systemmonitor"

    # Automations and helpers
    "automation"
    "scene"
    "script"

    # Web integrations
    "http"
    "stream"
      ];
      config = {
        # Includes dependencies for a basic setup
        default_config = {};
      };
    };

    # open firewall for Home Assistant’s web UI
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 8123 ];
    };
  };
}

