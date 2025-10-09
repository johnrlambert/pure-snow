{
  lib,
  config,
  pkgs,
  ...
}:

let
  enabled = config.homelab.nvim.enable or false;

  snacksNvim =
    if pkgs.vimPlugins ? snacks-nvim then
      pkgs.vimPlugins.snacks-nvim
    else
      pkgs.vimUtils.buildVimPlugin {
        pname = "snacks.nvim";
        version = "unstable-2025-10-01";
        src = pkgs.fetchFromGitHub {
          owner = "folke";
          repo = "snacks.nvim";
          rev = "main"; # pin a commit if you want
          hash = "sha256-CRmpopzcLgEoWkAPlUlUa5nwkb2RBhNNAdOHv8eZQww=";
        };
      };

  nvimAider =
    if pkgs.vimPlugins ? nvim-aider then
      pkgs.vimPlugins.nvim-aider
    else
      pkgs.vimUtils.buildVimPlugin {
        pname = "nvim-aider";
        version = "unstable-2025-10-01";
        src = pkgs.fetchFromGitHub {
          owner = "GeorgesAlkhouri";
          repo = "nvim-aider";
          rev = "main"; # pin a commit if you want
          hash = "sha256-CRmpopzcLgEoWkAPlUlUa5nwkb2RBhNNAdOHv8eZQww="; # paste the printed sha256 on rebuild
        };
      };
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
        snacksNvim
        nvimAider
      ];

      extraLuaConfig = builtins.readFile ./init.lua;
    };
  };
}
