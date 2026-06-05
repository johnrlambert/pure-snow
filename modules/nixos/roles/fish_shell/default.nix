{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;
let
  enabled = hasRole "fish" config.homelab.roles;
in
{
  options.homelab.roles.fish = mkEnableOption "Fish shell enabled";

  config = mkIf enabled {
    environment.systemPackages = with pkgs; 
    [pkgs.fish];
  };
}

