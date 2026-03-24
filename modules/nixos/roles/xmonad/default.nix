{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;

let
  enabled = config.homelab.roles.xmonad or false;
in
{
  options.homelab.roles.xmonad = mkEnableOption "XMonad window manager";

  config = mkIf enabled {
    services.xserver = {
      enable = true;

      displayManager = {
        lightdm.enable = true;
        defaultSession = "none+xmonad";

        # This runs for every graphical session (including XMonad via LightDM)
        sessionCommands = ''
          # Kill existing polybar instances
          ${pkgs.procps}/bin/killall -q polybar || true

          # Set wallpaper if present
          if [ -f "$HOME/wallpaper.jpg" ]; then
            ${pkgs.feh}/bin/feh --bg-scale "$HOME/wallpaper.jpg"
          fi

          # Start polybar
          ${pkgs.polybar}/bin/polybar example &
        '';
      };

      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };
    };

    services.picom.enable = true;

    environment.systemPackages = with pkgs; [
      xorg.xinit
      xorg.xrandr
      xmonad
      xmonad-contrib
      dmenu
      alacritty
      polybar
      feh
    ];
  };
}
