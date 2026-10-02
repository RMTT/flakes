{
  config,
  lib,
  ...
}:
let
  cfg = config.services.godel.wireguard;
  godelCfg = config.services.godel;
  registry = import ./registry.nix;
  nodeName = config.networking.hostName;

  selfNode =
    registry.${nodeName} or (throw "wireguard: node '${cfg.nodeName}' not found in registry");

  otherNodes =
    if selfNode.endpoint != null then
      lib.filterAttrs (name: _: name != nodeName) registry
    else
      lib.filterAttrs (name: node: name != nodeName && node.endpoint != null) registry;

  peers = lib.mapAttrsToList (
    _: node:
    {
      inherit (node) publicKey allowedIPs;
      persistentKeepalive = cfg.persistentKeepalive;
    }
    // lib.optionalAttrs (node.endpoint != null) {
      endpoint = node.endpoint;
    }
  ) otherNodes;
in
{
  options.services.godel.wireguard = {
    enable = lib.mkEnableOption "WireGuard mesh";

    privateKeyFile = lib.mkOption {
      type = lib.types.path;
    };

    persistentKeepalive = lib.mkOption {
      type = lib.types.int;
      default = 25;
    };

    nat = {
      enable = lib.mkEnableOption "NAT on the WireGuard interface";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedUDPPorts = [ 54321 ];
    networking.firewall.trustedInterfaces = [ "godel" ];

    networking.wg-quick.interfaces."godel" = {
      address = [ "${godelCfg.infra-ip}/32" ];
      listenPort = 54321;
      privateKeyFile = cfg.privateKeyFile;
      inherit peers;
    };
  };
}
