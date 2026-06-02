{ lib, config, inputs, system, ... }:

let
  cfg = config.homelab.pi;
  unstablePkgs = inputs.unstable.legacyPackages.${system};
  hasPiPackage = lib.hasAttrByPath [ "pi-coding-agent" ] unstablePkgs;
  piPackage = lib.getAttrFromPath [ "pi-coding-agent" ] unstablePkgs;
  sourceRoot = "${config.home.homeDirectory}/pure-snow/modules/home/pi";
  outOfStore = path: config.lib.file.mkOutOfStoreSymlink "${sourceRoot}/${path}";
in
{
  options.homelab.pi.enable = lib.mkEnableOption "Enable pi coding agent and user config";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = hasPiPackage;
        message = "inputs.unstable must provide pi-coding-agent for ${system}, but the attribute is missing.";
      }
    ];

    home.packages = [ piPackage ];

    home.file = {
      ".pi/agent/README.txt" = {
        source = outOfStore "README.txt";
        force = true;
      };
      ".pi/agent/settings.json" = {
        source = outOfStore "settings.json";
        force = true;
      };
      ".pi/agent/keybindings.json" = {
        source = outOfStore "keybindings.json";
        force = true;
      };
      ".pi/agent/models.json" = {
        source = outOfStore "models.json";
        force = true;
      };
      ".pi/agent/extensions/README.txt" = {
        source = outOfStore "extensions/README.txt";
        force = true;
      };
      ".pi/agent/prompts/README.txt" = {
        source = outOfStore "prompts/README.txt";
        force = true;
      };
      ".pi/agent/skills/README.txt" = {
        source = outOfStore "skills/README.txt";
        force = true;
      };
      ".pi/agent/themes/README.txt" = {
        source = outOfStore "themes/README.txt";
        force = true;
      };
    };
  };
}
