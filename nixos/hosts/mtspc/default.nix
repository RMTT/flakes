{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./secrets
  ];

  config = {
    system.stateVersion = "23.05";

    machine.bootloader.systemd-boot.enable = true;
    boot.kernelModules = [
      "kvm-amd"
      "k10temp"
    ];
    machine.graphics.enable = true;
    machine.networking.useNetworkd = false;
    machine.users.mt.hashedPassword = "$y$j9T$kabN1LYK8AhA4BJ6EgtwI0$fgyMHQ22A6y8VU9zNlPXOgkWvVcHkt3miKOHQS7N2F.";
    nixpkgs.hostPlatform = "x86_64-linux";
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    boot.binfmt.addEmulatedSystemsToNixSandbox = true;

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
    boot.resumeDevice = "/dev/disk/by-uuid/08810e32-8ed9-4e3f-bdfa-70ddd9688756";

    # kernel version
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    system.boot.loader.kernelFile = "vmlinuz"; # workaround
    boot.kernelParams = [
      "zswap.enabled=1"
      "zswap.compressor=zstd"
      "zswap.max_pool_percent=20"
      "zswap.shrinker_enabled=1"

      "pcie_aspm=force"
      "amdgpu.gpu_recovery=1"
      "amd_iommu=off"
      "idle=nomwait"
    ];
    boot.extraModprobeConfig = ''
      options nvidia NVreg_EnableS0ixPowerManagement=1
      options snd_hda_intel power_save=1
      options iwlwifi power_save=1
    '';

    services.asusd.enable = lib.mkDefault true;
    hardware.nvidia-container-toolkit.enable = true;
    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.production;
      dynamicBoost.enable = false;
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
    services.power-profiles-daemon.enable = true;
    powerManagement.enable = true;
    powerManagement.powertop = {
      enable = true;
      postStart = ''
        # find keyboard and mouse
        for dev in /sys/bus/usb/devices/*; do
          if [ -e "$dev/product" ]; then
            product=$(cat "$dev/product" 2>/dev/null)
            if echo "$product" | grep -iE "(keyboard|mouse|receiver|input|dongle)" > /dev/null; then
              if [ -e "$dev/power/control" ]; then
                echo "Disabling auto-suspend for $product ($dev)"
                echo "on" > "$dev/power/control"
              fi
            fi
          fi
        done
      '';
    };

    machine.desktop.enable = true;
    machine.development.enable = true;
    users.users.mt.shell = pkgs.zsh;

    # additional system packages
    environment.systemPackages = with pkgs; [
      perf
      moonlight-qt
      virt-manager
      virt-viewer
      winboat
      amdgpu_top
      qdiskinfo
      antigravity
      opencode-desktop
      powertop
    ];

    programs.throne = {
      enable = true;
      tunMode.enable = true;
      tunMode.setuid = true;
    };
    programs.steam = {
      enable = true;
      extest.enable = true;
      gamescopeSession = {
        enable = true;
      };
    };
    programs.gamescope = {
      enable = true;
      args = [
      ];
    };

    services.tailscale = {
      enable = true;
      openFirewall = true;
    };

    virtualisation.libvirtd.enable = true;
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

    services.meshcentral = {
      enable = true;
      settings = {
        domains = {
          "" = {
            NewAccounts = true;
          };
        };
      };
    };

    programs.librepods.enable = true;
    services.crossmacro = {
      enable = true;
      users = [ "mt" ];
    };
    services.cardwire = {
      enable = true;
      settings = {
        auto_apply_gpu_state = true;
        experimental_nvidia_block = true;
        battery_auto_switch = true;
        battery_auto_switch_mode = "hybrid";
      };
    };
  };
}
