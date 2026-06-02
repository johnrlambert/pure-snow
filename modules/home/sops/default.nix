# modules/home/sops/default.nix
{ lib, config, pkgs, inputs, ... }:

let
  enabled = config.homelab.sops.enable or false;
in {
  options.homelab.sops.enable = lib.mkEnableOption "Enable sops and tools";

  config = lib.mkIf enabled {
    home.packages = with pkgs; [ sops age ssh-to-age ];
    sops = {
      defaultSopsFile = "${inputs.secrets}/common.yaml";
      defaultSopsFormat = "yaml";
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      secrets.openai_api_key = { };
    };
  };
}

