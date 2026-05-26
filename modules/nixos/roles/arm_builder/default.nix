{ config, lib, ... }:

with lib;
with lib.homelab;
let
  enabled = config.homelab.roles.arm_builder or false;
in
{
  options.homelab.roles.arm_builder = mkEnableOption "Enable multi-arch builds for ARM targets via binfmt/QEMU";

  config = mkIf enabled {
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  };
}
