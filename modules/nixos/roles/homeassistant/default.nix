{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;
let
  enabled = config.homelab.roles.homeassistant or false;
in
{
  options.homelab.roles.homeassistant = mkEnableOption "Home Assistant";

  config = mkIf enabled {
    #### Home Assistant
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
        "cast"
        "sonos"
        "spotify"
        "radio_browser"

        # Voice / TTS
        "tts"
        "google_translate"
        "cloud"

        # Energy & sensors
        "energy"
        "mobile_app"
        "met"
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
      config.default_config = {};
    };

    #### Z-Wave JS (native) — HA connects to ws://127.0.0.1:3000
    services.zwave-js = {
      enable = true;
      port = 3000;
      serialPort = "/dev/ttyACM0";                # swap to /dev/serial/by-id/... when convenient
      # Some module code paths touch this; keep it out of the Nix store.
      secretsConfigFile = "/var/lib/zwave-js/secrets.json";
    };

    # Ensure the service can open the USB device without touching users.users.*
    systemd.services.zwave-js.serviceConfig.SupplementaryGroups = [ "dialout" ];

    # Create runtime dir + an empty secrets file with tight perms
    systemd.tmpfiles.rules = [
      "d /var/lib/zwave-js 0750 zwave-js zwave-js -"
      "f /var/lib/zwave-js/secrets.json 0600 zwave-js zwave-js -"
    ];

    # Let HA see serial devices (for other add-ons/integrations you may use)
    users.users.hass = {
      isSystemUser = true;
      extraGroups = [ "dialout" ];
    };

    # Open firewall for HA UI; Z-Wave JS stays local-only unless you expose it
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 8123 ];
      # allowedTCPPorts = [ 8123 3000 ]; # <- uncomment to expose Z-Wave JS off-box
    };
  };
}

