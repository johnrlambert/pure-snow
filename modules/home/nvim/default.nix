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
  options.homelab.nvim.enable = lib.mkEnableOption "Enable a minimal Neovim (your keymaps + Gruvbox + formatters for Python/Nix)";

  config = lib.mkIf enabled {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;

      # Only what we actually need: Gruvbox theme + Conform formatter orchestrator
      plugins = with pkgs.vimPlugins; [
        gruvbox-nvim
        conform-nvim
        nvim-tree-lua
        nvim-web-devicons
      ];

      # Load the Lua config below (no plugin managers, very small)
      extraLuaConfig = builtins.readFile ./init.lua;
    };

    # Only the formatters you asked for (Python + Nix)
    home.packages = with pkgs; [
      nixfmt-rfc-style # provides `nixfmt`
      black # Python formatter
      ruff # provides `ruff format`
    ];
  };
}
