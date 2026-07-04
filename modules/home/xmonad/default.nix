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

  polybarConfig = pkgs.replaceVars ./polybar_config.ini {
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

  kittyConfig = pkgs.writeText "kitty.conf" ''
    font_family JetBrainsMono Nerd Font Mono
    font_size 11.0

    window_padding_width 10

    map page_up scroll_page_up
    map page_down scroll_page_down

    background #282828
    foreground #ebdbb2
    selection_background #ebdbb2
    selection_foreground #282828

    color0  #282828
    color1  #cc241d
    color2  #98971a
    color3  #d79921
    color4  #458588
    color5  #b16286
    color6  #689d6a
    color7  #a89984

    color8  #928374
    color9  #fb4934
    color10 #b8bb26
    color11 #fabd2f
    color12 #83a598
    color13 #d3869b
    color14 #8ec07c
    color15 #ebdbb2
  '';
in
{
  options.homelab.xmonad.enable = mkEnableOption "User XMonad configuration";

  config = mkIf enabled {

    home.packages = with pkgs; [
      dmenu
      kitty
      polybar
      feh
      scrot
      haskellPackages.xmonad-contrib
    ];

    home.file.".config/polybar/config.ini".source = polybarConfig;
    home.file.".config/xmonad/xmonad.hs".source = ./xmonad.hs;
    home.file.".config/kitty/kitty.conf".source = kittyConfig;
  };
}
