{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;

let
  enabled = config.homelab.roles.xmonad or false;
in
{
  options.homelab.roles.xmonad = mkEnableOption "XMonad window manager";

  config = mkIf enabled {
    services.xserver = {
      enable = true;

      displayManager.lightdm.enable = true;

      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };
    };

    environment.systemPackages = with pkgs; [
      xorg.xinit
      xorg.xrandr
      xmonad
      xmonad-contrib
      dmenu
      alacritty
    ];
  };
}
