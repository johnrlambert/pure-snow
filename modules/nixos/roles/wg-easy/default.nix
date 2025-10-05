{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;

let
  cfg = config.homelab.roles.wg-easy;
  enabled = cfg.enable or false;

  uiBind = if cfg.exposeUi then "0.0.0.0" else "127.0.0.1";
in
{
  options.homelab.roles.wg-easy = {
    enable = mkEnableOption "wg-easy (WireGuard web UI)";

    host = mkOption {
      type = types.str;
      example = "witsendstables.duckdns.org";
      description = "Public hostname (DuckDNS, etc.) advertised to clients.";
    };

    port = mkOption {
      type = types.port;
      default = 51820;
      description = "WireGuard UDP port to listen on.";
    };

    uiPort = mkOption {
      type = types.port;
      default = 51821;
      description = "wg-easy web UI port.";
    };

    exposeUi = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If true, bind the UI on 0.0.0.0:${toString (cfg.uiPort or 51821)} and open the TCP port in the firewall.
        If false (default), bind to 127.0.0.1 and reach it via SSH tunnel.
      '';
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/wg-easy";
      description = "Persistent directory for WireGuard keys/configs inside the container.";
    };

    envFile = mkOption {
      type = types.path;
      default = "/etc/nixos/secrets/wg-easy.env";
      description = ''
        Environment file for secrets (at least: PASSWORD=...). Optional extras:
        WG_DEFAULT_DNS=1.1.1.1,1.0.0.1
      '';
    };

    allowedIPs = mkOption {
      type = types.str;
      default = "0.0.0.0/0,::/0";
      description = "Default AllowedIPs for new peers (full tunnel by default).";
    };
  };

  config = mkIf enabled {
    # Kernel bits + fw
    networking.wireguard.enable = true;

    networking.firewall = {
      enable = true;
      allowedUDPPorts = [ cfg.port ];
      allowedTCPPorts = mkIf cfg.exposeUi [ cfg.uiPort ];
    };

    # Container runtime (use docker by default; swap to podman if you prefer)
    virtualisation.docker.enable = true;
    # virtualisation.oci-containers.backend = "podman";  # uncomment to use podman instead

    # wg-easy container
    virtualisation.oci-containers.containers."wg-easy" = {
      image = "weejewel/wg-easy:latest";
      autoStart = true;

      volumes = [
        "${cfg.dataDir}:/etc/wireguard"
      ];

      # Capabilities + sysctls that wg-easy expects
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--cap-add=SYS_MODULE"
        "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
        "--sysctl=net.ipv4.ip_forward=1"
        "--sysctl=net.ipv6.conf.all.forwarding=1"
      ];

      # Port mappings
      ports = [
        "${toString cfg.port}:${toString cfg.port}/udp"
        "${uiBind}:${toString cfg.uiPort}:${toString cfg.uiPort}/tcp"
      ];

      # Public endpoint and defaults for generated peers
      environment = {
        WG_HOST = cfg.host;
        WG_PORT = toString cfg.port;
        WG_ALLOWED_IPS = cfg.allowedIPs;
        UI_TRAFFIC_STATS = "true";
      };

      # Secrets (PASSWORD, optional WG_DEFAULT_DNS, etc.)
      environmentFiles = [ cfg.envFile ];
    };

    # Helpful tools (optional)
    environment.systemPackages = with pkgs; [ wireguard-tools ];
  };
}

