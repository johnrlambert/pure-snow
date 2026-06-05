{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;
let
  enabled = hasRole "arm_builder" config.homelab.roles;
in
{
  options.homelab.roles.arm_builder = mkEnableOption "Enable multi-arch builds for ARM targets via binfmt/QEMU";

  config = mkIf enabled {
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    environment.systemPackages = [ pkgs.qemu_full ];
  };
}
