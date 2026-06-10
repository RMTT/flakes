{
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}:
let
  infra_node_ip = "198.19.19.8";
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko.nix
  ];

  config = {
    system.stateVersion = "26.05";
    nixpkgs.hostPlatform = "x86_64-linux";
    networking.useDHCP = false;
    machine.graphics.enable = false;
    machine.bootloader.grub = {
      enable = true;
      device = "/dev/sda";
    };
    machine.users.mt.hashedPassword = "$y$j9T$zlx88hQ0JZWjA58N4URWj/$iQVlklQzqsOJWdIqAEZIkoXAxlKSs3HC967V0qT2Dx8";

    systemd.network.networks.wan = {
      matchConfig.Name = "ens18";
      address = [ "${infra_node_ip}/24" ];
      gateway = [ "198.19.19.1" ];
      dns = [ "1.1.1.1" ];
    };

    boot.supportedFilesystems = [ "nfs" ];
    virtualisation.docker.enable = true;
    fileSystems."/mnt/cloud" = {
      device = "nas.infra.rmtt.host:/mnt/main/cloud";
      fsType = "nfs";
    };

    virtualisation.containers.enable = true;
    virtualisation.oci-containers = {
      backend = "docker";
      containers."nextcloud-aio-mastercontainer" = {
        image = "ghcr.io/nextcloud-releases/all-in-one:latest";
        ports = [
          "8080:8080"
        ];
        environment = {
          NEXTCLOUD_DATADIR = "/mnt/cloud";
          APACHE_PORT = "11000";
          APACHE_IP_BINDING = "0.0.0.0";
          APACHE_ADDITIONAL_NETWORK = "";
          SKIP_DOMAIN_VALIDATION = "true";
        };
        volumes = [
          "nextcloud_aio_mastercontainer:/mnt/docker-aio-config"
          "/var/run/docker.sock:/var/run/docker.sock:ro"
          "/mnt/cloud:/mnt/cloud"
        ];
      };
    };
  };
}
