  {lib,
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
  home.stateVersion = lib.mkDefault (osConfig.system.stateVersion or "24.11");
}
