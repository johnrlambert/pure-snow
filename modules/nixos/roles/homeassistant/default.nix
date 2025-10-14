{ config, lib, pkgs, ... }:

with lib;
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
        # Base + common integrations
        "default_config" "ssdp" "zeroconf" "esphome" "mqtt"
        "zwave_js" "zha" "matter" "bluetooth"
        # Media
        "cast" "sonos" "spotify" "radio_browser"
        # Voice / TTS
        "tts" "google_translate" "cloud"
        # Sensors / utilities
        "energy" "mobile_app" "met" "weather" "time_date" "systemmonitor"
        # Automations / web
        "automation" "scene" "script" "http" "stream"
      ];
      config.default_config = {};
    };

    #### Disable native Z-Wave JS (we'll run it in a container)
    services.zwave-js.enable = false;

    #### Container runtime (Docker) for Z-Wave JS UI
    virtualisation.docker.enable = true;

    #### Z-Wave JS UI container (includes server + web UI)
    virtualisation.oci-containers.containers.zwavejsui = {
      image = "ghcr.io/zwave-js/zwave-js-ui:latest";
      autoStart = true;
      ports = [ "8091:8091" "3000:3000" ];       # Web UI / WS API
      volumes = [ "/var/lib/zwave-js:/usr/src/app/store" ];
      extraOptions = [
        "--device=/dev/ttyACM0:/dev/zwave"
        "--group-add=dialout"
      ];
      environment = { TZ = "America/New_York"; };
    };

    #### Make sure the data dir exists (container writes configs here)
    systemd.tmpfiles.rules = [
      "d /var/lib/zwave-js 0750 root root -"
    ];

    #### HA user can access serial if needed for other integrations
    users.users.hass = {
      isSystemUser = true;
      extraGroups = [ "dialout" ];
    };

    #### Keep other services from grabbing the stick
    services.modemmanager.enable = false;

    #### Firewall
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 8123 8091 3000 ];
    };
  };
}
