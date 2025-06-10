  {lib,
  pkgs,
  inputs,
  config,
  ...
}:
with lib;
with lib.homelab; 
  
{
  snowfallorg.user.enable = true;
  snowfall.user.name = "john";
  homelab = {
    user = {
      name = "john";
      };
      fish.enable = true;
      };
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = lib.mkDefault (osConfig.system.stateVersion or "24.11");
}
