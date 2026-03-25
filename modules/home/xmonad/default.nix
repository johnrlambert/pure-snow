{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;

let
  enabled = config.homelab.xmonad.enable or false;

  colors = {
    bg = "#282828";
    bg_alt = "#3c3836";
    fg = "#ebdbb2";
    fg_dim = "#a89984";
    yellow = "#fabd2f";
    orange = "#fe8019";
    red = "#fb4934";
    green = "#b8bb26";
    aqua = "#8ec07c";
  };

  polybarConfig = pkgs.substituteAll {
    src = ./polybar_config.ini;

    colors_bg = colors.bg;
    colors_bg_alt = colors.bg_alt;
    colors_fg = colors.fg;
    colors_fg_dim = colors.fg_dim;
    colors_yellow = colors.yellow;
    colors_orange = colors.orange;
    colors_red = colors.red;
    colors_green = colors.green;
    colors_aqua = colors.aqua;
  };
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

    home.file.".config/polybar/config.ini".source = polybarConfig;
    home.file.".config/xmonad/xmonad.hs".source = ./xmonad.hs;
    home.file.".config/alacritty/alacritty.toml".source = ./alacritty.toml;
  };
}
