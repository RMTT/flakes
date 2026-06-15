{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              priority = 2;
              end = "-100G";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "/rootfs" = {
                    mountpoint = "/";
                  };
                  # for k3s
                  "/rancher" = {
                    mountOptions = [
                      "noatime"
                      "ssd"
                      "nodatacow"
                    ];
                    mountpoint = "/var/lib/rancher";
                  };
                  "/nix" = {
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "ssd"
                    ];
                    mountpoint = "/nix";
                  };
                };
              };
            };
            cache = {
              priority = 3;
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountOptions = [
                  "defaults"
                  "noatime"
                ];
                mountpoint = "/cache";
              };
            };
          };
        };
      };
    };
  };
}
