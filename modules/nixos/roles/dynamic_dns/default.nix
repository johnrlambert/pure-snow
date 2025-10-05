{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;
let
  enabled = config.homelab.roles.dynamic_dns or false;
in
{
  options.homelab.roles.dynamic_dns = mkEnableOption "Dynamic DNS";

  config = mkIf enabled {
	services.duckdns = {
		enable = true;
		domains = ["witsendstables"];
		tokenFile = "/etc/nixos/secrets/duckdns.token";
		};
  };
}

