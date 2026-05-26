{ pkgs, lib, modulesPath, config, inputs, ... }:
with lib;
with lib.homelab;
let
  hostSopsFile = "${inputs.secrets}/${config.networking.hostName}.yaml";
  defaultSopsFile =
    if builtins.pathExists hostSopsFile
    then hostSopsFile
    else "${inputs.secrets}/common.yaml";
in
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  networking.hostName = "malacabeza";
  networking.useDHCP = lib.mkDefault true;

  networking.wireless = {
    enable = true;
    secretsFile = config.sops.secrets.wireless.path;
    networks."RobbisRouter".pskRaw = "ext:psk_robbisrouter";
  };

  system.stateVersion = "25.11";

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  hardware.enableRedistributableFirmware = true;

  # The generic aarch64 sd-image profile enables broad "all hardware" initrd
  # support. That is useful for installer media, but it pulls in modules that
  # do not exist as loadable modules in the rpi4 kernel package (for example
  # dw-hdmi), which breaks the initrd shrink step. Keep this image Pi-specific.
  hardware.enableAllHardware = lib.mkForce false;
  boot.initrd.availableKernelModules = lib.mkForce [
    "mmc_block"
    "sd_mod"
    "ext4"
    "usbhid"
    "hid_generic"
    "xhci_hcd"
    "xhci_pci"
    "pcie-brcmstb"
    "reset-raspberrypi"
  ];

  sops = {
    defaultSopsFile = defaultSopsFile;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/john/.config/sops/age/keys.txt";

    secrets.wireless = {
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

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

  environment.systemPackages = with pkgs; [
    gitMinimal
    vim
  ];
}
