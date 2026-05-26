{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;
let
  enabled = config.homelab.roles.blender or false;
in
{
  options.homelab.roles.blender = mkEnableOption "Blender";

  config = mkIf enabled {
    environment.systemPackages = with pkgs; [
      blender
    ];
  };
}
