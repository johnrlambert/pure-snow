{ pkgs, lib, modulesPath, ... }:
with lib;
with lib.homelab;

{
  imports = [
    "${modulesPath}/virtualisation/disk-image.nix"
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  networking.hostName = "malacabeza-vm";
  networking.useDHCP = lib.mkDefault true;

  system.stateVersion = "25.11";

  homelab.roles.homeassistant = true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  image = {
    format = "qcow2";
    efiSupport = true;
  };

  boot.loader.efi.canTouchEfiVariables = false;
  boot.kernelParams = [ "console=ttyAMA0,115200n8" ];
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_mmio"
    "virtio_blk"
    "virtio_scsi"
    "virtio_net"
  ];

  virtualisation = {
    diskSize = 16384;
    memorySize = 2048;
    cores = 4;
    graphics = false;
    useBootLoader = true;
    useEFIBoot = true;
    forwardPorts = [
      {
        from = "host";
        host.port = 2223;
        guest.port = 22;
      }
    ];
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  systemd.services."serial-getty@ttyAMA0".enable = true;

  users.mutableUsers = true;
  users.users.john = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;
    initialPassword = "changeme";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINN9vMs23mK242aEaHuwwTqcVoABjY4f82PicdnnnFqy john@wef"
    ];
  };

  programs.fish.enable = true;

  # Keep the VM image lean and avoid spending time building manual/docs
  # artifacts such as man-db during fast QEMU iteration.
  documentation = {
    enable = false;
    man.enable = false;
    info.enable = false;
    doc.enable = false;
    nixos.enable = false;
    man.generateCaches = lib.mkForce false;
  };

  environment.systemPackages = with pkgs; [
    gitMinimal
    vim
  ];
}
