{
  lib,
  config,
  pkgs,
  ...
}:

let
  enabled = config.homelab.nvim.enable or false;

in
{
  options.homelab.nvim.enable = lib.mkEnableOption "Enable Neovim with nvim-aider";

  config = lib.mkIf enabled {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;

      # Keep your existing list, just add Snacks + nvim-aider + (optionally) devicons
      plugins = with pkgs.vimPlugins; [
        gruvbox-nvim
        conform-nvim
        nvim-tree-lua
        nvim-web-devicons # icons (optional but nice)
      ];

      extraLuaConfig = builtins.readFile ./init.lua;
    };
  };
}
