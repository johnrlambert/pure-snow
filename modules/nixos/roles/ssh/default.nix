{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;

let
  enabled = hasRole "ssh" config.homelab.roles;
in
{
  options.homelab.roles.ssh =
    mkEnableOption "SSH remote access system.";

  config = mkIf enabled {
    services.openssh = {
      enable = true;
      ports = [2222]; # Change to a non-standard port
      permitRootLogin = "no"; # Disable root login
      passwordAuthentication = false; # Disable password authentication
      extraConfig = ''
        AllowUsers john
        # Additional security settings
        MaxAuthTries 3
        LogLevel VERBOSE
      '';
    };

    # Optionally, configure fail2ban for additional security
#    security.pam.services.sshd.fail2ban.enable = true;
  };
}

