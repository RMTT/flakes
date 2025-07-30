{ lib, config, pkgs, modules, ... }:
with lib;
let
  cfg = config.services.godel;
  port = 12025;
  json = pkgs.formats.json { };
  customConfig = {
    private_key = config.sops.secrets.godel.path;
    daemon = {
      ifname = "godel";
      network = cfg.network;
      mode = cfg.mode;
      extra_network = cfg.extra_network;
      extra_ip = cfg.extra_ip;
    };
    organization = "rmtt.tech";
    common_name = config.networking.hostName;
    endpoints = if (cfg.public) then [{
      address_family = "ip4";
      address = "${config.networking.hostName}.rmtt.host";
      port = port;
      serial_number = 0;
    }] else [
      {
        address_family = "ip4";
        address = null;
        serial_number = 0;
        port = port;
      }
      {
        address_family = "ip6";
        address = null;
        serial_number = 1;
        port = port;
      }
    ];
  };
in {
  imports = with modules; [ services ];
  options = {
    services.godel = {
      enable = mkEnableOption "enable godel service";
      network = mkOption { type = types.str; };
      mode = mkOption { type = types.str; };
      extra_network = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      extra_ip = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      public = mkEnableOption "public ip";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.trustedInterfaces = [ "godel" ];
    environment.etc = {
      "aronet/config.json" = {
        source = (json.generate "config.json" customConfig);
        mode = "0400";
      };
    };
    services.aronet = {
      enable = true;
      config = "/etc/aronet/config.json";
      registry = ./registry.json;
    };
  };
}
