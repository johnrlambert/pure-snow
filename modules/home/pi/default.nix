{ lib, config, inputs, system, ... }:

let
  cfg = config.homelab.pi;
  unstablePkgs = inputs.unstable.legacyPackages.${system};
in
{
  options.homelab.pi.enable = lib.mkEnableOption "Enable pi coding agent and user config";

  config = lib.mkIf cfg.enable {
    home.packages = [ unstablePkgs.pi-coding-agent ];

    home.file = {
      ".pi/agent/README.txt".source = ./README.txt;
      ".pi/agent/settings.json".source = ./settings.json;
      ".pi/agent/keybindings.json".source = ./keybindings.json;
      ".pi/agent/models.json".source = ./models.json;
      ".pi/agent/extensions/README.txt".source = ./extensions/README.txt;
      ".pi/agent/prompts/README.txt".source = ./prompts/README.txt;
      ".pi/agent/skills/README.txt".source = ./skills/README.txt;
      ".pi/agent/themes/README.txt".source = ./themes/README.txt;
    };
  };
}
