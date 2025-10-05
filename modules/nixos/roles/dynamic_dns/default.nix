{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;
let
  enabled = config.homelab.roles.dynamic_dns or false;
in
{
  options.homelab.roles.dynamic_dns = mkEnableOption "Dynamic DNS";

  config = mkIf enabled {
	 services.ddclient = {
    enable = true;
    interval = "5min";                 # how often to update
    protocol = "duckdns";
    server = "www.duckdns.org";
    ssl = true;
    # Use WAN autodetect:
    use = "web, web=checkip.amazonaws.com/";  # or: "web"
    # DuckDNS uses the *password* as the token; username/login is ignored.
    passwordFile = "/etc/nixos/secrets/duckdns.token";
    domains = [ "witsendstables" ];    # e.g. "witsend" => witsend.duckdns.org
  };

};
}

