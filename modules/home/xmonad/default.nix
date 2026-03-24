{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;

let
  enabled = config.homelab.xmonad.enable or false;
in
{
  options.homelab.xmonad.enable = mkEnableOption "User XMonad configuration";

  config = mkIf enabled {

    home.packages = with pkgs; [
      dmenu
      alacritty
      polybar
      feh
    ];

    home.file.".config/polybar/config.ini".text = ''
      [bar/example]
      width = 100%
      height = 24
      background = #222222
      foreground = #ffffff

      modules-left = xworkspaces
      modules-right = date

      [module/xworkspaces]
      type = internal/xworkspaces

      [module/date]
      type = internal/date
      interval = 5
      date = %Y-%m-%d %H:%M
    '';

    home.file.".config/xmonad/xmonad.hs".source = ./xmonad.hs;
  };
}
