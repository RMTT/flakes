{
  lib,
  config,
  pkgs,
  ...
}:
let
  importYaml =
    file:
    builtins.fromJSON (
      builtins.readFile (
        pkgs.runCommand "yaml-to-json" { } ''
          ${pkgs.yj}/bin/yj < "${file}" > "$out"
        ''
      )
    );
  raw_list = importYaml ../../../dns/hosts.yaml;
  flatHosts = map (x: {
    ip = x.value;
    host = "${x.name}.${x.zone}";
  }) raw_list;

  grouped = lib.groupBy (x: x.ip) flatHosts;

  cfg = config.services.godel.hostsRecord;
in
{
  options = {
    services.godel.hostsRecord.enable = lib.mkEnableOption "enable godel";
  };
  config = lib.mkIf cfg.enable {
    networking.hosts = lib.mapAttrs (ip: records: map (r: "${r.host}") records) grouped;
  };
}
