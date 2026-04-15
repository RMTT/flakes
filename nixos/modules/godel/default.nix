{
  lib,
  ...
}:
{
  imports = [
    ./k3s.nix
    ./overlay.nix
    ./uptime.nix
    ./hosts.nix
  ];

  options = {
    services.godel = {
      infra-ip = lib.mkOption { type = lib.types.str; };
    };
  };
}
