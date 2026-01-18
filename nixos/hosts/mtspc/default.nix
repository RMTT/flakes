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

    machine.graphics.enable = true;
    fileSystems = {
      "/" = {
        device = "UUID=d907c147-e5c8-4bc5-8483-de76504e2815";
        fsType = "btrfs";
        options = [
          "subvol=@"
          "compress=zstd"
          "rw"
          "relatime"
          "ssd"
          "space_cache=v2"
        ];
      };
      "/home" = {
        device = "UUID=d907c147-e5c8-4bc5-8483-de76504e2815";
        fsType = "btrfs";
        options = [
          "subvol=@home"
          "compress=zstd"
          "rw"
          "relatime"
          "ssd"
          "space_cache=v2"
        ];
      };
      "/toplevel" = {
        device = "UUID=d907c147-e5c8-4bc5-8483-de76504e2815";
        fsType = "btrfs";
        options = [ "subvol=/" ];
      };
      "/boot" = {
        device = "UUID=8220-7E12";
        fsType = "vfat";
      };
    };
    swapDevices = [ { device = "/dev/disk/by-uuid/ce573198-7727-4c4e-b119-b85e50341830"; } ];

    boot.kernel.sysctl = {
      "kernel.yama.ptrace_scope" = 0;
    };
    boot.kernelParams = [
      "amd_pstate=guided"
    ];
    hardware.cpu.amd.updateMicrocode = true;

    # kernel version
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

    services.xserver.videoDrivers = [
      "amdgpu"
      "nvidia"
    ];
    boot.initrd.kernelModules = [ "nvidia" ];
    boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
    hardware.nvidia-container-toolkit.enable = true;
    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      modesetting.enable = true;
      prime = {
        nvidiaBusId = "PCI:1:0:0";
        amdgpuBusId = "PCI:6:0:0";
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
      powerManagement = {
        enable = true;
        finegrained = true;
      };
      open = true;
    };

    machine.desktop.enable = true;
    machine.development.enable = true;
    # https://wayland.freedesktop.org/libinput/doc/1.28.1/clickpad-with-right-button.html
    environment.etc."libinput/local-overrides.quirks".text = pkgs.lib.mkForce ''
      [Laptop Touchpad]
      MatchName=UNIW0001:00 093A:0255 Touchpad
      MatchUdevType=touchpad
      MatchDMIModalias=dmi:*svnMECHREVO:pnCANGLONGSeries:*
      AttrEventCode=-BTN_RIGHT
    '';

    # default shell
    users.users.mt.shell = pkgs.zsh;

    # additional system packages
    environment.systemPackages = with pkgs; [
      config.boot.kernelPackages.perf
      moonlight-qt
      virt-manager
      virt-viewer
    ];

    programs.steam = {
      enable = true;
      extest.enable = true;
    };

    services.tailscale = {
      enable = true;
      openFirewall = true;
    };

    # services.ollama = {
    #   enable = true;
    #   package = pkgs.ollama-cuda;
    # };
    services.logind.settings.Login = {
      IdleAction = "ignore";
    };

    virtualisation.docker = {
      enable = true;
      daemon.settings = {
        iptables = false;
        ip6tables = false;
        ipv6 = true;
        fixed-cidr-v6 = "2001:db8:ffff::/64";
      };
    };
    services.netflow = {
      enable = true;
    };
    services.meshcentral.enable = true;
    virtualisation.incus = {
      enable = true;
      ui.enable = true;
    };
  };
}
