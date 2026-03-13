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
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      nerd-fonts.symbols-only
      nerd-fonts.jetbrains-mono

      # If your nixpkgs doesn't support override above, try:
      # nerd-fonts-symbols
    ];
  };
}
