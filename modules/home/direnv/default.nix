# modules/home/direnv/default.nix
{ lib, config, pkgs, ... }:

let
  cfg = config.homelab.direnv;
in
{
  options.homelab.direnv = {
    enable = lib.mkEnableOption "Enable direnv integration";
    enableNixDirenv = lib.mkEnableOption "Enable nix-direnv (use flake in .envrc)";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;

      # Optional but strongly recommended when you use flakes:
      nix-direnv.enable = lib.mkIf cfg.enableNixDirenv true;

      # Nice defaults:
      config = {
        warn_timeout = "10s";
      };
    };

    # If you want it to be active in fish automatically, HM does this
    # as long as programs.fish.enable is on somewhere.
  };
}

