{ config, lib, ... }:

with lib;
with lib.homelab;
let
  enabled = hasRole "homeassistant" config.homelab.roles;
in
{
  options.homelab.roles.homeassistant = mkEnableOption "Home Assistant";

  config = mkIf enabled {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers.homeassistant = {
      image = "ghcr.io/home-assistant/home-assistant:stable";
      autoStart = true;
      volumes = [
        "/var/lib/home-assistant:/config"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        TZ = "America/New_York";
      };
      extraOptions = [
        "--network=host"
        "--privileged"
      ];
    };

    # Z-Wave JS UI runs well as a companion container and is typically
    # available for arm64. Keep it enabled for VM testing unless/until a
    # specific image issue shows up.
    virtualisation.oci-containers.containers.zwavejsui = {
      image = "ghcr.io/zwave-js/zwave-js-ui:latest";
      autoStart = true;
      ports = [ "8091:8091" "3000:3000" ];
      volumes = [ "/var/lib/zwave-js:/usr/src/app/store" ];
      extraOptions = [
        "--device=/dev/ttyACM0:/dev/zwave"
        "--group-add=dialout"
      ];
      environment = {
        TZ = "America/New_York";
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/home-assistant 0750 root root -"
      "d /var/lib/zwave-js 0750 root root -"
    ];

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 8123 8091 3000 ];
    };
  };
}
