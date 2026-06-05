{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;
let
  enabled = hasRole "blender" config.homelab.roles;
in
{
  options.homelab.roles.blender = mkEnableOption "Blender";

  config = mkIf enabled {
    environment.systemPackages = with pkgs; [
      blender
    ];
  };
}
