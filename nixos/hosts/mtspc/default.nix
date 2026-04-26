{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./secrets
    ./vm.nix
  ];

  config = {
    system.stateVersion = "23.05";

    boot.kernelModules = [
      "kvm-amd"
      "k10temp"
    ];
    machine.graphics.enable = true;

    hardware.enableAllFirmware = true;
    boot.initrd.systemd.enable = true;
    boot.initrd.luks.devices."root".device = "/dev/disk/by-uuid/87bae457-3808-4edd-aef4-2017cc04c566";
    fileSystems."/" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = [ "compress=zstd,subvol=@" ];
    };
    fileSystems."/home" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = [ "compress=zstd,subvol=@home" ];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/2F21-D492";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
    swapDevices = [ { device = "/dev/disk/by-uuid/08810e32-8ed9-4e3f-bdfa-70ddd9688756"; } ];

    # kernel version
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    boot.kernelParams = [
      "zswap.enabled=1"
      "zswap.compressor=zstd"
      "zswap.max_pool_percent=20"
      "zswap.shrinker_enabled=1"
    ];

    services = {
      asusd.enable = lib.mkDefault true;
      supergfxd.enable = lib.mkDefault true;
    };
    hardware.nvidia-container-toolkit.enable = true;
    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      dynamicBoost.enable = true;
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = true;
      prime = {
        nvidiaBusId = "PCI:1:0:0";
        amdgpuBusId = "PCI:5:0:0";
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
      open = true;
    };

    machine.desktop.enable = true;
    machine.development.enable = true;

    # additional system packages
    environment.systemPackages = with pkgs; [
      perf
      moonlight-qt
      virt-manager
      virt-viewer
      amdgpu_top
    ];

    programs.steam = {
      enable = true;
      extest.enable = true;
    };

    services.tailscale = {
      enable = true;
      openFirewall = true;
    };

    virtualisation.docker = {
      enable = true;
      daemon.settings = {
        storage-driver = "overlay2";
        ipv6 = false;
        fixed-cidr-v6 = "2001:db8:ffff::/64";
      };
    };
    services.sblite.enable = true;
    networking.firewall.trustedInterfaces = [ "sing-box" ];

    services.meshcentral.enable = true;

    programs.librepods.enable = true;
  };
}
