{
  pkgs,
  lib,
  namespace,
  ...
}:

with lib;
with lib.${namespace};

{
  imports = [ ./hardware.nix ];

  networking.hostName = "server";

  system.stateVersion = "25.05";
}

