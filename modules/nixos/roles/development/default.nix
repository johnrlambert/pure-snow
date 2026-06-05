{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;
let
  enabled = hasRole "development" config.homelab.roles;
in
{
  options.homelab.roles.development = mkEnableOption "Development goodies";

  config = mkIf enabled {
    environment.systemPackages = with pkgs; 
    [pkgs.git
    pkgs.neovim];
  };
}

