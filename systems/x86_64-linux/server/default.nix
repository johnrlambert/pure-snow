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

  homelab.config.users.user = {
   isAdmin = true;
   extraGroups = [ "networkmanager" ];
   hashedPassword = "$6$9X3coPdeSIaUth1C$CwHEy.Ot3idZi8Uqcwe7lhPj7Pf/oNIwnKEnvInxBenAPdB4SUHMffZ68dgwJ.PQ2p.ZggVvkBwEv0Ypv19jy.";
  };

}

