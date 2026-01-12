# Base configuratioj
{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.machine.base;
in
with lib;
{
  options.machine.base = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # enable unfree pkgs
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.joypixels.acceptLicense = true;
    nixpkgs.config.segger-jlink.acceptLicense = true;

    # binary cache
    nix.settings.substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    nix.settings.trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    nix.settings.trusted-users = [
      "root"
    ];
    nix.optimise.automatic = true;
    nix.gc.automatic = true;

    # enable flakes
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.loader.systemd-boot.configurationLimit = 10;
    boot.loader.grub.configurationLimit = 10;

    boot.kernelModules = [
      "wireguard"
      "ip_vs"
    ];
    boot.supportedFilesystems = [
      "btrfs"
    ];

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
    boot.kernel.sysctl = {
      "net.core.devconf_inherit_init_net" = 1;
    };

    # timezone
    time.timeZone = "Asia/Shanghai";
    networking.timeServers = [
      "ntp.aliyun.com"
      "time.apple.com"
      "time.asia.apple.com"
    ];

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
      fd
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
      nix-tree
      nix-du
      tree
      zfs
      lsof
      python3
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
      settings = {
        PasswordAuthentication = false;
      };
    };

    # cpu governor
    powerManagement.cpuFreqGovernor =
      mkIf (config.hardware.cpu.intel.updateMicrocode || config.hardware.cpu.amd.updateMicrocode)
        (
          (lib.strings.optionalString config.hardware.cpu.intel.updateMicrocode "ondemand")
          + (lib.strings.optionalString config.hardware.cpu.amd.updateMicrocode "schedutil")
        );

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
    services.fwupd.enable = true;
  };
}
