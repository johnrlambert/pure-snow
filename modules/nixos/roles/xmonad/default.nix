{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;

let
  enabled = hasRole "xmonad" config.homelab.roles;
in
{
  options.homelab.roles.xmonad = mkEnableOption "XMonad window manager";

  config = mkIf enabled {
    services.xserver = {
      enable = true;

      displayManager = {
        lightdm.enable = true;
        defaultSession = "none+xmonad";

        sessionCommands = ''
          ${pkgs.procps}/bin/killall -q polybar || true

          if [ -f "$HOME/wallpaper.jpg" ]; then
            ${pkgs.feh}/bin/feh --bg-scale "$HOME/wallpaper.jpg"
          fi

          ${pkgs.polybar}/bin/polybar example &
        '';
      };

      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;

        config = builtins.readFile ../../../home/xmonad/xmonad.hs;
      };
    };

    services.picom.enable = true;

    environment.systemPackages = with pkgs; [
      xorg.xinit
      xorg.xrandr
      dmenu
      kitty
      xterm
      polybar
      xmonad-with-packages
      haskellPackages.xmonad-contrib
      feh
      ghc
      xclip
      scrot
    ];
  };
}
