{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];  # Swap to "kvm-amd" if AMD CPU
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  # Data drives (mounted read-write post-install; labels assumed — check with lsblk -f if wrong)
  fileSystems."/data18tb" = {
    device = "/dev/sda1";  # Use UUID if label missing: e.g., "UUID=d34f950d-8125-43be-9f4c-2976fd420265"
    fsType = "ext4";
  };

  fileSystems."/data500" = {
    device = "/dev/nvme1n1p1";
    fsType = "ext4";
  };

  swapDevices = [ ];  # Add if you want swap

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
