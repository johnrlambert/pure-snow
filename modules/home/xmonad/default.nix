{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;

let
  enabled = config.homelab.home.xmonad or false;
in
{
  options.homelab.home.xmonad = mkEnableOption "User XMonad configuration";

  config = mkIf enabled {
    xsession = {
      enable = true;

      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };

      initExtra = ''
        # Kill existing polybar instances (prevents duplicates on restart)
        killall -q polybar || true

        # Set wallpaper (only if file exists)
        if [ -f "$HOME/wallpaper.jpg" ]; then
          feh --bg-scale "$HOME/wallpaper.jpg"
        fi

        # Start polybar
        polybar example &
      '';
    };

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

    home.file.".xmonad/xmonad.hs".text = ''
      import XMonad

      main :: IO ()
      main = xmonad def
        { terminal = "alacritty"
        , modMask = mod4Mask
        }
    '';
  };
}
