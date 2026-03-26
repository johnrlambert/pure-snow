# modules/home/fish/default.nix
{ lib, config, pkgs, inputs, ... }:

let
  enabled = config.homelab.fish.enable or false;

  system = pkgs.stdenv.hostPlatform.system;
  unstablePkgs = inputs.unstable.packages.${system};
in {
  options.homelab.fish.enable = lib.mkEnableOption "Enable fish shell and tools";

  config = lib.mkIf enabled {
    home.packages = with pkgs; [
      emacs
      fish
      eza
      bat
      tree
      xsel
    ] ++ [
      unstablePkgs."pi-coding-agent"
    ];

    programs.fish = {
      enable = true;
      shellAliases = {
        cat = "bat";
      };
    };
  };
}
