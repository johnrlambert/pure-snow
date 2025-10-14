{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
with lib.homelab;

{
  imports = [ ./hardware.nix ];
  networking.hostName = "server";
  system.stateVersion = "24.11";
  homelab.roles.chrome = true;
  homelab.roles.dynamic_dns = true;
  homelab.roles.fish = true;
  homelab.roles.guacamole = true;
  homelab.roles."wg-easy" = {
  	enable = true;
	host = "witsendstables.duckdns.org";
	exposeUi = true;
	};
  homelab.roles.homeassistant = true;
  homelab.roles.desktop.pantheon = true;
  homelab.roles.cockpit = true;
  homelab.config.users.user = {
   isAdmin = true;
   extraGroups = [ "networkmanager" ];
   hashedPassword = "$6$9X3coPdeSIaUth1C$CwHEy.Ot3idZi8Uqcwe7lhPj7Pf/oNIwnKEnvInxBenAPdB4SUHMffZ68dgwJ.PQ2p.ZggVvkBwEv0Ypv19jy.";
  };
 homelab.config.users.john = {
   isAdmin = true;
   extraGroups = [ "networkmanager" ];
   hashedPassword = "$6$9X3coPdeSIaUth1C$CwHEy.Ot3idZi8Uqcwe7lhPj7Pf/oNIwnKEnvInxBenAPdB4SUHMffZ68dgwJ.PQ2p.ZggVvkBwEv0Ypv19jy.";
  };
   programs.fish.enable = true;
   users.users.john.shell = pkgs.fish;   
}

