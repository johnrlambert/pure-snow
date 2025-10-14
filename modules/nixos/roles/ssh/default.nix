{ config, lib, pkgs, ... }:

with lib;

let
  enabled = config.homelab.roles.ssh or false;
in
{
  options.homelab.roles.ssh =
    mkEnableOption "SSH remote access system.";

  config = mkIf enabled {
    services.openssh = {
      enable = true;
      port = 2222; # Change to a non-standard port
      permitRootLogin = "no"; # Disable root login
      passwordAuthentication = false; # Disable password authentication
      allowUsers = [ "your-username" ]; # Replace with allowed usernames
      extraConfig = ''
        # Additional security settings
        MaxAuthTries 3
        LogLevel VERBOSE
      '';
    };

    # Optionally, configure fail2ban for additional security
    security.pam.services.sshd.fail2ban.enable = true;
  };
};

