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
        "tts" "google_translate" "cloud" "openai_conversation"
        # Sensors / utilities
        "energy" "mobile_app" "met" "weather" "time_date" "systemmonitor"
        # Automations / web
        "automation" "scene" "script" "http" "stream"
        # Voice PE stuff (???)
        "improv_ble" "elevenlabs" "wyoming"
      ];
      config.default_config = {};
    };

    #### Disable native Z-Wave JS (we'll run it in a container)
    services.zwave-js.enable = false;

    #### Container runtime (Docker) for Z-Wave JS UI
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";
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
    
  virtualisation.oci-containers.containers.wyoming-whisper = {
    image = "docker.io/rhasspy/wyoming-whisper:latest";
    autoStart = true;
    ports = [ "10300:10300" ];
    environment = {
      # Set thread count to match your CPU cores
      CTRANSLATE2_NUM_THREADS = "8";
    };

    # Command options for fast CPU inference
    cmd = [
      "--model" "tiny-int8"
      "--language" "en"
      "--beam-size" "1"
      "--uri" "tcp://0.0.0.0:10300"
      "--data-dir" "/data"
    ];

    extraOptions = [ ];
    };
    #### Make sure the data dir exists (container writes configs here)
    systemd.tmpfiles.rules = [
      "d /var/lib/zwave-js 0750 root root -"
    ];
    systemd.services."docker-wyoming-whisper".serviceConfig = {
      Restart = "always";
      RestartSec = "2s";
    };

    #### HA user can access serial if needed for other integrations
    users.users.hass = {
      isSystemUser = true;
      extraGroups = [ "dialout" ];
    };


    #### Firewall
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 8123 8091 3000 10300];
    };
  };
}
