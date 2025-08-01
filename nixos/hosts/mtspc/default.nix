{ pkgs, lib, config, modules, ... }: {
  imports = with modules; [
    globals
    base
    fs
    networking
    desktop
    developments
    services
    docker
    godel

    ./vm.nix
  ];

  system.stateVersion = "23.05";

  # set filesystems mount
  fs.btrfs.device = "d907c147-e5c8-4bc5-8483-de76504e2815";
  fs.btrfs.volumes = {
    "/" = [ "subvol=@" "compress=zstd" "rw" "relatime" "ssd" "space_cache=v2" ];
    "/home" =
      [ "subvol=@home" "compress=zstd" "rw" "relatime" "ssd" "space_cache=v2" ];
  };
  fs.boot.device = "8220-7E12";
  fs.swap.device = "ce573198-7727-4c4e-b119-b85e50341830";

  boot.kernel.sysctl = { "kernel.yama.ptrace_scope" = 0; };
  boot.kernelParams = [ "amd_pstate=guided" ];
  hardware.cpu.amd.updateMicrocode = true;

  # kernel version
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  base.gl.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  boot.kernelModules = [ "nvidia" "nvidia_drm" "nvidia_uvm" ];
  hardware.nvidia = {
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

  services.logind.lidSwitch = "ignore";
  desktop.niri.enable = true;
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
  ];

  programs.steam = {
    enable = true;
    extest.enable = true;
  };

  virtualisation.docker = { storageDriver = "btrfs"; };

  virtualisation.libvirtd.enable = true;

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  services.meshcentral.enable = true;
}
