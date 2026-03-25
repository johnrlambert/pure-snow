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
    home.file.".config/polybar/config.ini".source = ./polybar_config.ini;
    home.file.".config/xmonad/xmonad.hs".source = ./xmonad.hs;

    home.file.".config/alacritty/alacritty.toml".source = ./alacritty.toml;
  };
}
