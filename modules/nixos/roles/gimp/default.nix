{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;
let
  enabled = hasRole "gimp" config.homelab.roles;
in
{
  options.homelab.roles.gimp = mkEnableOption "GIMP with common plugins";

  config = mkIf enabled {
    environment.systemPackages = with pkgs; [
      gimp-with-plugins
      gimpPlugins.gmic
      gmic
    ];
  };
}
