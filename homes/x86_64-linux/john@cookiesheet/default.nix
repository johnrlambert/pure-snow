{
  lib,
  pkgs,
  inputs,
  config,
  osConfig,
  ...
}:
with lib;
with lib.homelab;

{
  homelab.fish.enable = true;
  homelab.emacs.enable = true;
  homelab.direnv.enable = true;
  homelab.nvim.enable = true;
  homelab.fonts.enable = true;
  homelab.aider.enable = true;
  homelab.sops.enable = true;
  home.stateVersion = lib.mkDefault (osConfig.system.stateVersion or "25.11");
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "John Lambert";
      };
      extraConfig = {
        core.editor = "nvim";
        pull.rebase = true;
        init.defaultBranch = "main";
        alias.lg = "log --oneline --graph --decorate";
      };
    };
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
      };
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/id_ed25519";
      };
    };
  };

  services.ssh-agent.enable = true;
  home.sessionVariables.OPENAI_API_KEY_FILE =
    config.sops.secrets.openai_api_key.path;

  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "exa -lah";
      vim = "nvim";
    };
    interactiveShellInit = ''
      # Apply Gruvbox theme
      set -gx OPENAI_API_KEY (cat $OPENAI_API_KEY_FILE)
      set -g fish_color_normal brblack
      set -g fish_color_command brgreen
      set -g fish_color_comment brblue
      set -g fish_color_error brred
      set -g fish_color_selection --background=brblack
      set -g fish_color_search_match --background=brblack
      set -g fish_color_operator brcyan
      set -g fish_color_escape brmagenta
      set -g fish_color_param brcyan
      set -g fish_color_quote bryellow
      set -g fish_color_redirection brmagenta
      set -g fish_color_end brmagenta
    '';
  };
}
