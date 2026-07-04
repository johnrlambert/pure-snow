# modules/home/sops/default.nix
{ lib, config, pkgs, inputs, ... }:

let
  enabled = config.homelab.sops.enable or false;
in {
  options.homelab.sops.enable = lib.mkEnableOption "Enable sops and tools";

  config = lib.mkIf enabled {
    home.packages = with pkgs; [ sops age ssh-to-age ];
    home.sessionVariables.SOPS_AGE_SSH_PRIVATE_KEY_FILE =
      "${config.home.homeDirectory}/id_ed25519";

    systemd.user.services.sops-nix.Service.Environment = [
      "SOPS_AGE_SSH_PRIVATE_KEY_FILE=${config.home.homeDirectory}/id_ed25519"
    ];

    sops = {
      defaultSopsFile = "${inputs.secrets}/common.yaml";
      defaultSopsFormat = "yaml";
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      age.sshKeyPaths = [ "${config.home.homeDirectory}/id_ed25519" ];
      secrets.openai_api_key = { };
    };
  };
}

