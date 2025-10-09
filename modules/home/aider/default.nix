# modules/home/aider/default.nix
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:

let
  unstable = inputs.unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  enabled = config.homelab.aider.enable or false;
in
{
  options.homelab.aider.enable = lib.mkEnableOption "Enable aider";

  config = lib.mkIf enabled {
    home.packages = with pkgs; [ unstable.aider-chat-full ];
  };
}
