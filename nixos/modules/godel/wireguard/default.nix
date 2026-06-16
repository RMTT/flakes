{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.godel.wireguard;
  godelCfg = config.services.godel;
  registry = import ./registry.nix;
  nodeName = config.networking.hostName;

  selfNode =
    registry.${nodeName} or (throw "wireguard: node '${cfg.nodeName}' not found in registry");

  otherNodes =
    if selfNode.endpoint != null then
      filterAttrs (name: _: name != nodeName) registry
    else
      filterAttrs (name: node: name != nodeName && node.endpoint != null) registry;

  peers = mapAttrsToList (
    _: node:
    {
      inherit (node) publicKey allowedIPs;
      persistentKeepalive = cfg.persistentKeepalive;
    }
    // optionalAttrs (node.endpoint != null) {
      endpoint = node.endpoint;
    }
  ) otherNodes;
in
{
  options.services.godel.wireguard = {
    enable = mkEnableOption "WireGuard mesh";

    privateKeyFile = mkOption {
      type = types.path;
    };

    persistentKeepalive = mkOption {
      type = types.int;
      default = 25;
    };

    nat = {
      enable = mkEnableOption "NAT on the WireGuard interface";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedUDPPorts = [ 51820 ];
    networking.firewall.trustedInterfaces = [ "godel" ];

    networking.wg-quick.interfaces."godel" = {
      address = [ "${godelCfg.infra-ip}/32" ];
      listenPort = 51820;
      privateKeyFile = cfg.privateKeyFile;
      inherit peers;
    };
  };
}
