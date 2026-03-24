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
    };

    home.packages = with pkgs; [
      dmenu
      alacritty
    ];

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
