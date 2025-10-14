{ config, lib, pkgs, ... }:

with lib;

let
  enabled = config.homelab.roles.ssh or false;
in
{
  options.homelab.roles.ssh =
    mkEnableOption "SSH remote access system.";

  config = mkIf enabled {
    services.openssh = {
      enable = true;
      port = 22;
        };
      };
};

