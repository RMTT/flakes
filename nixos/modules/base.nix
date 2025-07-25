# Base configuratioj
{ pkgs, lib, config, ... }:
let cfg = config.base;
in with lib; {
  options.base = {
    gl.enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    # enable unfree pkgs
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.joypixels.acceptLicense = true;
    nixpkgs.config.segger-jlink.acceptLicense = true;

    # binary cache
    nix.settings.substituters = [
      "https://cache.garnix.io"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
    ];
    nix.settings.trusted-public-keys =
      [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
    nix.settings.trusted-users = [ "root" "mt" ];
    nix.optimise.automatic = true;
    nix.gc.automatic = true;

    # enable flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.loader.systemd-boot.configurationLimit = 10;
    boot.loader.grub.configurationLimit = 10;

    boot.kernelModules = [ "wireguard" "ip_vs" ];
    boot.supportedFilesystems = [ "ntfs" "btrfs" ];

    # common initrd options
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "uas"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
      "btrfs"
    ];

    # sysctl
    boot.kernel.sysctl = { "net.core.devconf_inherit_init_net" = 1; };

    # timezone
    time.timeZone = "Asia/Shanghai";
    time.hardwareClockInLocalTime = true;

    # locale
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
      "zh_TW.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
    ];

    # console
    console = {
      font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
      packages = with pkgs; [ terminus_font ];
      useXkbConfig = true;
    };

    # system packages
    environment.systemPackages = with pkgs; [
      unrar
      smartmontools
      parted
      bind
      htop
      gitFull
      git-lfs
      ipvsadm
      file
      wget
      curl
      pciutils
      usbutils
      inetutils
      fastfetch
      zsh
      python3
      tmux
      ripgrep
      iptables
      nftables
      tcpdump
      man-pages
      gnupg
      sops
      jq
      unzip
      zip
      bridge-utils
      home-manager
      wireguard-tools
      efibootmgr
      virtiofsd
      hwloc
      openssl
      sysstat
      lm_sensors
      iperf
      moreutils
      sshuttle
      mtr
      hugo
    ];

    # set XDG viarables
    environment.sessionVariables = rec {
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_BIN_HOME = "$HOME/.local/bin";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";

      PATH = [ "${XDG_BIN_HOME}" ];
    };

    # set default editor to nvim
    programs.neovim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
    };

    # enable ssh
    services.openssh = {
      enable = true;
      settings = { PasswordAuthentication = false; };
    };

    # cpu governor
    powerManagement.cpuFreqGovernor = mkIf
      (config.hardware.cpu.intel.updateMicrocode
        || config.hardware.cpu.amd.updateMicrocode)
      ((lib.strings.optionalString config.hardware.cpu.intel.updateMicrocode
        "ondemand")
        + (lib.strings.optionalString config.hardware.cpu.amd.updateMicrocode
          "schedutil"));

    # enable acpid
    services.acpid.enable = true;

    # hardware related
    hardware.enableRedistributableFirmware = true;
    hardware.enableAllFirmware = true;

    # enable zsh
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableGlobalCompInit = false;
      shellInit = ''
        bindkey -e
      '';
    };

    # main user
    security.sudo = { wheelNeedsPassword = false; };
    users.mutableUsers = true;
    users.groups.mt = { gid = 1000; };
    users.users.mt = {
      isNormalUser = true;
      home = "/home/mt";
      description = "mt";
      group = "mt";
      uid = 1000;
      extraGroups = [
        "wheel"
        "networkmanager"
        (mkIf config.virtualisation.docker.enable "docker")
        "video"
        "kvm"
        "users"
        "uinput"
        "i2c"
        (mkIf config.virtualisation.libvirtd.enable "libvirt")
        (mkIf config.virtualisation.virtualbox.host.enable "vboxusers")
      ];
      initialHashedPassword =
        "$y$j9T$v3KSiMJEpJdcbN4osJbMF0$Qfgg9i/ozgLjDhOg/WZmSrg8vuiNQSrSWivWKvjATN7";
      openssh.authorizedKeys.keyFiles = [ ../../secrets/ssh_key.pub ];
    };

    # configure tmux
    programs.tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      extraConfig = ''
        set -s default-terminal 'screen-256color'
      '';
    };

    # yubikey related
    services.udev.packages = with pkgs; [ yubikey-personalization ];
    services.pcscd.enable = true;

    # enable yubikey otp
    security.pam.yubico = {
      enable = true;
      mode = "challenge-response";
    };

    # opengl and hardware acc
    hardware.graphics = mkIf cfg.gl.enable {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libva
        mesa
        vaapiVdpau
        libvdpau-va-gl
        amdvlk
      ];
    };

    services.fwupd.enable = true;

  };
}
