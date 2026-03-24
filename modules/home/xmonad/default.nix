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
      [colors]
      bg = #282828
      bg-alt = #3c3836
      fg = #ebdbb2
      fg-dim = #a89984
      yellow = #fabd2f
      orange = #fe8019
      red = #fb4934
      green = #b8bb26
      aqua = #8ec07c

      [bar/example]
      width = 100%
      height = 28
      offset-x = 0
      offset-y = 0

      background = ''${colors.bg}
      foreground = ''${colors.fg}

      padding-left = 2
      padding-right = 2

      module-margin = 2

      tray-position = right
      tray-padding = 2

      font-0 = "Helvetica Neue LT Std:size=10;2"
      font-1 = "Symbols Nerd Font Mono:size=10;2"
      font-2 = "JetBrainsMono Nerd Font Mono:size=10;2"

      modules-left = xworkspaces
      modules-center = xwindow
      modules-right = journal cpu memory date

      [module/xworkspaces]
      type = internal/xworkspaces
      enable-click = true
      enable-scroll = true

      label-active = %name%
      label-active-foreground = ''${colors.bg}
      label-active-background = ''${colors.yellow}
      label-active-padding = 1

      label-occupied = %name%
      label-occupied-padding = 1

      label-urgent = %name%!
      label-urgent-background = ''${colors.red}
      label-urgent-padding = 1

      label-empty = %name%
      label-empty-foreground = ''${colors.fg-dim}
      label-empty-padding = 1

      [module/xwindow]
      type = internal/xwindow
      label =  %title:0:50:...%

      [module/journal]
      type = custom/text
      content = ""
      content-foreground = ''${colors.yellow}
      click-left = emacsclient -c -a emacs "(progn (org-journal-new-entry) nil)"

      [module/cpu]
      type = internal/cpu
      interval = 2
      format-prefix = " "
      format-prefix-foreground = ''${colors.green}
      label = %percentage%%

      [module/memory]
      type = internal/memory
      interval = 2
      format-prefix = " "
      format-prefix-foreground = ''${colors.aqua}
      label = %percentage_used%%

      [module/date]
      type = internal/date
      interval = 5
      date = "%Y-%m-%d %H:%M"
      label = " %date%"
      label-foreground = ''${colors.orange}
    '';

    home.file.".config/xmonad/xmonad.hs".source = ./xmonad.hs;

    home.file.".config/alacritty/alacritty.toml".source = ./alacritty.toml;
  };
}
