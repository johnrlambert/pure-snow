# modules/home/aider/default.nix
{ inputs, lib, config, pkgs, ... }:

let
  cfg = config.homelab.aider;
  unstable = inputs.unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  aiderPkg = unstable.aider-chat-full; # or unstable.aider-chat if you want smaller
in
{
  options.homelab.aider = {
    enable = lib.mkEnableOption "Enable aider";
    model  = lib.mkOption {
      type = lib.types.str;
      default = "openai/gpt-5.3-chat-latest";
      description = "Default model string passed to aider (provider must support it).";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ aiderPkg ];

    # Manage Aider config in a reproducible way:
    home.file.".aider.conf.yml".text = ''
      model: ${cfg.model}
    '';

    home.sessionVariables = {
      AIDER_MODEL = cfg.model;
      # OPENAI_API_KEY = "...";  # don't hardcode secrets in nix
    };
  };
}

