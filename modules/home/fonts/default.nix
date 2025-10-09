# modules/home/fish/default.nix
{
  lib,
  config,
  pkgs,
  ...
}:

let
  enabled = config.homelab.fonts.enable or false;
in
{
  options.homelab.fonts.enable = lib.mkEnableOption "Get some solid fonts for icons, etc.";

  config = lib.mkIf enabled {
    home.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })

      # If your nixpkgs doesn't support override above, try:
      # nerd-fonts-symbols
    ];
  };
}
