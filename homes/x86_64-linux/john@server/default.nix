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
  homelab.nvim.enable = true;
  homelab.fonts.enable = true;
  homelab.aider.enable = true;
  home.stateVersion = lib.mkDefault (osConfig.system.stateVersion or "24.11");
  programs.git = {
    enable = true;
    userName = "John Lambert";
    userEmail = "john@example.com";
    extraConfig = {
      core.editor = "nvim";
      pull.rebase = true;
      init.defaultBranch = "main";
      alias.lg = "log --oneline --graph --decorate";
    };
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/id_ed25519";
      };
    };
  };

  services.ssh-agent.enable = true;

  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "exa -lah";
      vim = "nvim";
    };
    interactiveShellInit = ''
      source ~/OPENAI_API_KEY.env
      # Apply Gruvbox theme
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
