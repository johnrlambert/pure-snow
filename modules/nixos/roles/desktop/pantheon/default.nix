{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;
let
  enabled = config.homelab.roles.desktop.pantheon or false;
in
{
  options.homelab.roles.desktop.pantheon = mkEnableOption "Pantheon desktop environment";

  config = mkIf enabled {
    services.xserver.enable = true;
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.desktopManager.pantheon.enable = true;

    fonts.packages = with pkgs; [ dejavu_fonts ];
  };
}

