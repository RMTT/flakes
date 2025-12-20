{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./secrets
    ./disk-config.nix
  ];

  config = {
    system.stateVersion = "25.05";
    zramSwap = {
      enable = true;
      memoryPercent = 20;
    };
    hardware.cpu.intel.updateMicrocode = true;
    services.zfs.trim.enable = true;
    boot.supportedFilesystems = [
      "btrfs"
    ];
    boot.kernel.sysctl = {
      "vm.overcommit_memory" = 1;
      "net.ipv6.route.max_size" = 409600;
    };
    boot.kernelParams = [ "intel_iommu=on" ];
    boot.initrd.kernelModules = [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"

      "i915"
    ];

    # gpu setting
    # services.xserver.videoDrivers = [ "i915" ];
    machine.graphics.enable = false;

    networking.useNetworkd = true;

    # enable onedrive
    services.onedrive.enable = true;

    # set msmtp, for sending notification
    programs.msmtp = {
      enable = true;
      accounts = {
        default = {
          auth = true;
          tls = true;
          tls_starttls = true;
          from = "notification@rmtt.tech";
          host = "smtp.mail.me.com";
          port = 587;
          user = "mt@rmtt.tech";
          passwordeval = "${pkgs.coreutils}/bin/cat ${config.sops.secrets.smtp-pass.path}";
        };
      };
    };

    # config smartd, monitor disk status
    services.smartd = {
      enable = true;
      notifications.test = true;
      notifications.mail = {
        enable = true;
        recipient = "d.rong@outlook.com";
        sender = "notification@rmtt.tech";
      };
    };

    # ups
    power.ups = {
      enable = true;
      mode = "netserver";
      ups.main = {
        driver = "usbhid-ups";
        port = "auto";
        directives = [
          "default.battery.charge.low = 20"
          "default.battery.runtime.low = 180"
        ];
      };

      upsmon = {
        monitor.mt = {
          user = "mt";
          system = "main@localhost";
          passwordFile = config.sops.secrets.ups_pass.path;
        };
      };

      users.mt = {
        upsmon = "primary";
        instcmds = [ "ALL" ];
        actions = [ "SET" ];
        passwordFile = config.sops.secrets.ups_pass.path;
      };

      upsd = {
        enable = true;
        listen = [
          {
            address = "0.0.0.0";
            port = 3493;
          }
        ];
      };
    };

    services.tailscale = {
      enable = true;
      openFirewall = true;
    };

    users.users.mt.extraGroups = [ "incus-admin" ];
    virtualisation.incus = {
      enable = true;
      package = pkgs.incus;
      ui.enable = true;
    };

    services.prometheus = {
      exporters.node.enable = true;
      exporters.smartctl = {
        enable = true;
        user = "root";
      };
    };
  };
}
