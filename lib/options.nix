# lib/options.nix
{ lib }:

{
  homelab.user = lib.mkOption {
    type = lib.types.attrs;
    default = {};
    description = "User metadata for homelab modules";
  };

  homelab.fish.enable = lib.mkEnableOption "Enable Fish shell in Home Manager";
}

