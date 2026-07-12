{ lib, config, ... }:
let
  cfg = config.services.godel.dns;
  godelCfg = config.services.godel;
in
{
  options = with lib; {
    services.godel.dns = {
      enable = mkEnableOption "enable bind9 dns";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.bind-keys = {
      sopsFile = ./secrets/keys.conf.enc;
      format = "binary";
      owner = "named";
    };
    systemd.tmpfiles.rules =
      let
        rmtt-tech = ''
          $TTL 3600
          @   IN  SOA ns1.rmtt.tech. admin.rmtt.tech. (
                      2026071201 ; Serial
                      86400      ; Refresh
                      7200       ; Retry
                      3600000    ; Expire
                      3600 )     ; Minimum TTL
          @   IN  NS  ns1.rmtt.tech.
          ns1 IN  A   ${godelCfg.infra-ip}
        '';
        escaped-rmtt-tech = builtins.replaceStrings [ "\n" ] [ "\\n" ] rmtt-tech;

        rmtt-host = ''
          $TTL 3600
          @   IN  SOA ns1.rmtt.host. admin.rmtt.host. (
                      2026071201 ; Serial
                      86400      ; Refresh
                      7200       ; Retry
                      3600000    ; Expire
                      3600 )     ; Minimum TTL
          @   IN  NS  ns1.rmtt.host.
          ns1 IN  A   ${godelCfg.infra-ip}
        '';
        escaped-rmtt-host = builtins.replaceStrings [ "\n" ] [ "\\n" ] rmtt-host;
      in
      [
        "d /var/lib/bind 0770 named named - -"
        "f+ /var/lib/bind/db.rmtt.tech 0644 named named - ${escaped-rmtt-tech}"
        "f+ /var/lib/bind/db.rmtt.host 0644 named named - ${escaped-rmtt-host}"
      ];
    services.bind = {
      enable = true;
      ipv4Only = true;
      listenOn = [ "${godelCfg.infra-ip}" ];
      extraConfig = ''include "${config.sops.secrets.bind-keys.path}";'';
      checkConfig = false;
      zones = [
        {
          name = "rmtt.tech";
          master = true;
          file = "/var/lib/bind/db.rmtt.tech";
          extraConfig = ''
            allow-update { key terraform-key. ;};
          '';
        }
        {
          name = "rmtt.host";
          master = true;
          file = "/var/lib/bind/db.rmtt.host";
          extraConfig = ''
            allow-update { key terraform-key. ;};
          '';
        }
      ];
    };
  };
}
