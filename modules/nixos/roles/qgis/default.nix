{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;
let
  enabled = hasRole "qgis" config.homelab.roles;
in
{
  options.homelab.roles.qgis = mkEnableOption "QGIS desktop GIS";

  config = mkIf enabled {
    environment.systemPackages = with pkgs; [ qgis ];
  };
}
