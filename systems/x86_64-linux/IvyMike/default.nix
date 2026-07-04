# This file is generated from README.org. Edit README.org and retangle.
{ pkgs, lib, config, inputs, ... }:
let
  spec = lib.importTOML ./machine.toml;

  pkgByName = name: builtins.getAttr name pkgs;

  roleAttrs =
    lib.foldl'
      lib.recursiveUpdate
      { }
      (map
        (role:
          lib.setAttrByPath
            ([ "homelab" "roles" ] ++ lib.splitString "." role)
            true)
        spec.system.roles);
in
lib.recursiveUpdate
  {
    imports = [ ./hardware.nix ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = spec.system.hostname;
    time.timeZone = spec.system.timeZone;
    system.stateVersion = spec.system.stateVersion;

    users.mutableUsers = spec.users.mutable;

    services.printing.enable = spec.printing.enable;
    services.printing.drivers = map pkgByName spec.printing.drivers;

    services.webdav = {
      enable = spec.webdav.enable;
      user = spec.webdav.user;
      group = spec.webdav.group;
      environmentFile = config.sops.templates."webdav.env".path;
      settings = {
        address = spec.webdav.address;
        port = spec.webdav.port;
        directory = spec.webdav.directory;
        permissions = spec.webdav.permissions;
        log.format = spec.webdav.logFormat;
        users = spec.webdav.users;
      };
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts =
      spec.firewall.tailscaleTCPPorts;

    systemd.services.webdav = {
      requires = [ "sops-install-secrets.service" ];
      after = [ "sops-install-secrets.service" ];
    };

    environment.systemPackages = map pkgByName spec.packages.system;

    sops = {
      useSystemdActivation = spec.sops.useSystemdActivation;
      environment.SOPS_AGE_SSH_PRIVATE_KEY_FILE = spec.sops.sshPrivateKeyFile;
      defaultSopsFile = "${inputs.secrets}/${config.networking.hostName}.yaml";
      defaultSopsFormat = spec.sops.defaultSopsFormat;
      age.keyFile = spec.sops.ageKeyFile;
      age.sshKeyPaths = spec.sops.ageSshKeyPaths;

      secrets.webdav_username.sopsFile = "${inputs.secrets}/${spec.sops.sharedSecretsFile}";
      secrets.webdav_password.sopsFile = "${inputs.secrets}/${spec.sops.sharedSecretsFile}";

      templates."webdav.env" = {
        content = ''
          WEBDAV_USERNAME=${config.sops.placeholder.webdav_username}
          WEBDAV_PASSWORD=${config.sops.placeholder.webdav_password}
        '';
        owner = "root";
        group = "root";
        mode = "0400";
        restartUnits = [ "webdav.service" ];
      };
    };

    users.users.john = {
      isNormalUser = spec.users.john.isNormalUser;
      extraGroups = spec.users.john.extraGroups;
      shell = pkgByName spec.users.john.shell;
      openssh.authorizedKeys.keys = spec.users.john.authorizedKeys;
    };

    programs.fish.enable = spec.programs.fish.enable;
  }
  roleAttrs
