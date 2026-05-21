{ lib, config, ... }:
let
  cfg = config.services.godel.traefik;
in
{
  options = with lib; {
    services.godel.traefik = {
      enable = mkEnableOption "enable traefik";
      configFile = mkOption {
        type = types.path;
      };
      envFile = mkOption {
        type = types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.traefik = {
      enable = true;
      staticConfigOptions = {
        api = {
          dashboard = true;
          insecure = true;
        };
        entryPoints = {
          traefik = {
            address = ":9000";
          };
          web = {
            address = ":80";
          };
          websecure = {
            address = ":443";
          };
        };
        certificatesResolvers.dnsresolver.acme = {
          email = "iamrmttt@gmail.com";
          dnsChallenge = {
            provider = "cloudflare";
            delayBeforeCheck = 60;
            resolvers = [
              "223.5.5.5:53"
              "8.8.8.8:53"
            ];
          };
        };
      };
      environmentFiles = [ cfg.envFile ];
      dynamicConfigFile = cfg.configFile;
    };
  };
}
