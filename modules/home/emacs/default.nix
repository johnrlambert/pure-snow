# modules/home/emacs/default.nix
{
  lib,
  config,
  pkgs,
  ...
}:

let
  enabled = config.homelab.emacs.enable or false;
in
{
  options.homelab.emacs.enable = lib.mkEnableOption "Enable emacs with custom init.el";

  config = lib.mkIf enabled {
    home.packages = with pkgs; [ emacs ];
    home.file.".emacs.d/init.el".source = ./init.el;

  };
}
