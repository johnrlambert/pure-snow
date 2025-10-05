{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;

let
  cfg = config.homelab.roles."wg-easy";
  enabled = cfg.enable or false;
  uiBind = if cfg.exposeUi then "0.0.0.0" else "127.0.0.1";
in
{
  options.homelab.roles."wg-easy" = {
    enable = mkEnableOption "wg-easy (WireGuard web UI)";

    host = mkOption {
      type = types.str;
      example = "witsendstables.duckdns.org";
      description = "Public hostname (DuckDNS, etc.) advertised to clients.";
    };

    port = mkOption { type = types.port; default = 51820; };
    uiPort = mkOption { type = types.port; default = 51821; };

    exposeUi = mkOption {
      type = types.bool; default = false;
      description = "Bind UI on 0.0.0.0 (LAN) when true; 127.0.0.1 (SSH tunnel) when false.";
    };

    dataDir = mkOption {
      type = types.path; default = "/var/lib/wg-easy";
      description = "Persistent directory for WireGuard keys/configs.";
    };

    envFile = mkOption {
      type = types.path; default = "/etc/nixos/secrets/wg-easy.env";
      description = "Env file with PASSWORD=... (and optional WG_DEFAULT_DNS, etc.).";
    };

    allowedIPs = mkOption {
      type = types.str; default = "0.0.0.0/0,::/0";
      description = "Default AllowedIPs for new peers.";
    };
  };

  config = mkIf enabled {
    networking.wireguard.enable = true;

    networking.firewall = {
      enable = true;
      allowedUDPPorts = [ cfg.port ];
      allowedTCPPorts = mkIf cfg.exposeUi [ cfg.uiPort ];
    };

    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers."wg-easy" = {
      image = "weejewel/wg-easy:latest";
      autoStart = true;

      volumes = [ "${cfg.dataDir}:/etc/wireguard" ];

      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--cap-add=SYS_MODULE"
        "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
        "--sysctl=net.ipv4.ip_forward=1"
        "--sysctl=net.ipv6.conf.all.forwarding=1"
      ];

      ports = [
        "${toString cfg.port}:${toString cfg.port}/udp"
        "${uiBind}:${toString cfg.uiPort}:${toString cfg.uiPort}/tcp"
      ];

      environment = {
        WG_HOST = cfg.host;
        WG_PORT = toString cfg.port;
        WG_ALLOWED_IPS = cfg.allowedIPs;
        UI_TRAFFIC_STATS = "true";
      };

      environmentFiles = [ cfg.envFile ];
    };

    environment.systemPackages = with pkgs; [ wireguard-tools ];
  };
}

