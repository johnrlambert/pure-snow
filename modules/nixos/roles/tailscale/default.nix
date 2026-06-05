{ config, lib, inputs, ... }:

with lib;
with lib.homelab;
let
  cfg = config.homelab.roles.tailscale;
  enabled = hasRole "tailscale" config.homelab.roles;
  hostSopsFile = "${inputs.secrets}/${config.networking.hostName}.yaml";
  defaultSopsFile =
    if builtins.pathExists hostSopsFile
    then hostSopsFile
    else "${inputs.secrets}/common.yaml";
  authKeySecret =
    if cfg.authKeySecret != null
    then cfg.authKeySecret
    else "tailscale_auth_key_${config.networking.hostName}";
in
{
  options.homelab.roles.tailscale = {
    enable = mkEnableOption "Tailscale mesh VPN";

    authKeySecret = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "tailscale_auth_key_server";
      description = ''
        Name of the SOPS secret that contains this host's Tailscale auth key.
        When left unset, the module defaults to tailscale_auth_key_<hostname>.
      '';
    };

    sopsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = lib.literalExpression ''"${inputs.secrets}/IvyMike.yaml"'';
      description = ''
        SOPS file containing the auth key. Defaults to ${inputs.secrets}/<hostname>.yaml
        and falls back to ${inputs.secrets}/common.yaml when the host file does not yet exist.
      '';
    };

    useRoutingFeatures = mkOption {
      type = types.enum [
        "none"
        "client"
        "server"
        "both"
      ];
      default = "client";
      description = "Routing mode passed through to services.tailscale.useRoutingFeatures.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Open the Tailscale UDP port in the firewall.";
    };

    extraUpFlags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "--ssh" ];
      description = "Extra flags passed to tailscale up during autoconnect.";
    };

    extraSetFlags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "--accept-routes" ];
      description = "Extra flags passed to tailscale set after startup.";
    };
  };

  config = mkIf enabled {
    sops.secrets."${authKeySecret}" = {
      sopsFile = if cfg.sopsFile != null then cfg.sopsFile else defaultSopsFile;
      owner = "root";
      group = "root";
      mode = "0400";
    };

    services.tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets."${authKeySecret}".path;
      openFirewall = cfg.openFirewall;
      useRoutingFeatures = cfg.useRoutingFeatures;
      extraUpFlags = cfg.extraUpFlags;
      extraSetFlags = cfg.extraSetFlags;
    };
  };
}
