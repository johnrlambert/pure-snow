# modules/home/sops/default.nix
{ lib, config, pkgs, inputs, ... }:

let
  enabled = config.homelab.sops.enable or false;
in {
  options.homelab.sops.enable = lib.mkEnableOption "Enable sops and tools";

  config = lib.mkIf enabled {
    home.packages = with pkgs; [ sops age ssh-to-age];
    sops = {
      defaultSopsFile = "${inputs.secrets}/common.yaml";
      defaultSopsFormat = "yaml";
      age.sshKeyPaths = [ "/home/john/id_ed25519" ];
      secrets.openai_api_key = { };
      };
  };
}

