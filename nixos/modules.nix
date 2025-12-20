{
  base = ./modules/base.nix;
  mt = ./modules/user-mt.nix;
  graphics = ./modules/graphics.nix;
  development = ./modules/developments.nix;
  networking = ./modules/networking.nix;
  firewall = ./modules/firewall.nix;
  preset-firewall = ./modules/preset-firewall.nix;
  godel = ./modules/godel;
  secrets = ./modules/secrets;
  desktop = ./modules/desktop;
  netflow = ./modules/netflow;
  services = ./modules/services;
}
