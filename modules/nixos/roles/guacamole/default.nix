# modules/nixos/roles/guacamole/default.nix
{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;
let
  enabled = config.homelab.roles.guacamole or false;
in
{
  options.homelab.roles.guacamole = mkEnableOption "Apache Guacamole (no LDAP; file-auth quick start)";

  config = mkIf enabled {
    #### guacd (server)
    services.guacamole-server = {
      enable = true;
      host = "127.0.0.1";
      port = 4822;
    };

    #### Web client
    services.guacamole-client = {
      enable = true;
      enableWebserver = true;  # http://127.0.0.1:8080/guacamole
      settings = {
        "guacd-hostname" = "127.0.0.1";
        "guacd-port"     = 4822;
        # No LDAP/OIDC here on purpose — swap later when ready.
      };
    };

    #### Minimal file-auth so you can log in and test
    # NOTE: This stores a plaintext password in the Nix store (fine for testing only).
    environment.etc."guacamole/user-mapping.xml".text = ''
      <user-mapping>
        <!-- username: admin / password: change-me -->
        <authorize username="admin" password="change-me" encoding="plain">
          <!-- Example SSH connection back to this host -->
          <connection name="Server SSH">
            <protocol>ssh</protocol>
            <param name="hostname">127.0.0.1</param>
            <param name="port">22</param>
            <param name="username">john</param>
          </connection>
        </authorize>
      </user-mapping>
    '';

    #### Open the Guacamole web UI port (optional if proxying via nginx)
    networking.firewall.allowedTCPPorts = mkAfter [ 8080 ];
  };
}

