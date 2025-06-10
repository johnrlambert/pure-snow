{ config, lib, ... }:
with lib;
with lib.homelab;
{
  options.homelab.config.users = mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        extraGroups = mkOption {
          type = types.listOf types.str;
          default = [];
        };
        isAdmin = mkOption {
          type = types.bool;
          default = false;
        };
        hashedPassword = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "SHA512-hashed password for this user";
        };
      };
    });
    default = {};
  };

  config.users.users =
    lib.mapAttrs (name: userCfg: {
      isNormalUser = true;
      home = "/home/${name}";
      extraGroups = userCfg.extraGroups ++ lib.optional userCfg.isAdmin "wheel";
      inherit (userCfg) hashedPassword;
    }) config.homelab.config.users;
}

