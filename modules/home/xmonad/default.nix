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
      haskellPackages.xmonad-contrib
    ];

    home.file.".config/polybar/config.ini".text = ''
      [bar/example]
      width = 100%
      height = 28
      offset-x = 0
      offset-y = 0

      background = #222222
      foreground = #ffffff

      padding-left = 2
      padding-right = 2

      module-margin = 2

      tray-position = right
      tray-padding = 2

      font-0 = "JetBrainsMono Nerd Font Mono:size=10;2"
      font-1 = "Symbols Nerd Font Mono:size=10;2"

      modules-left = xworkspaces
      modules-center = xwindow
      modules-right = cpu memory date

      [module/xworkspaces]
      type = internal/xworkspaces
      enable-click = true
      enable-scroll = true

      label-active = %name%
      label-active-foreground = #ffffff
      label-active-background = #444444
      label-active-padding = 1

      label-occupied = %name%
      label-occupied-padding = 1

      label-urgent = %name%!
      label-urgent-background = #ff5555
      label-urgent-padding = 1

      label-empty = %name%
      label-empty-foreground = #888888
      label-empty-padding = 1

      [module/xwindow]
      type = internal/xwindow
      label =  %title:0:50:...%

      [module/cpu]
      type = internal/cpu
      interval = 2
      format-prefix = " "
      label = %percentage%%

      [module/memory]
      type = internal/memory
      interval = 2
      format-prefix = " "
      label = %percentage_used%%

      [module/date]
      type = internal/date
      interval = 5
      date = "%Y-%m-%d %H:%M"
      label = " %date%"
    '';

    home.file.".config/xmonad/xmonad.hs".source = ./xmonad.hs;

    home.file.".config/alacritty/alacritty.toml".source = ./alacritty.toml;
  };
}
