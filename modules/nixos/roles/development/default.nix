{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;
let
  enabled = config.homelab.roles.development or false;
in
{
  options.homelab.roles.development = mkEnableOption "Development goodies";

  config = mkIf enabled {
    environment.systemPackages = with pkgs; [pkgs.git]
  };
}

