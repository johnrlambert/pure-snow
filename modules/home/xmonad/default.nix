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
      height = 24
      background = #222222
      foreground = #ffffff

      font-0 = "JetBrainsMono Nerd Font Mono:size=10;2"

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

    home.file.".config/alacritty/alacritty.toml".source = ./alacritty.toml;
  };
}
