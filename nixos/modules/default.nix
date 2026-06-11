{
  base = ./base.nix;
  opengpg = ./opengpg.nix;
  nix-config = ./nix-config.nix;
  mt = ./user-mt.nix;
  graphics = ./graphics.nix;
  development = ./developments.nix;
  networking = ./networking.nix;
  firewall = ./firewall.nix;
  preset-firewall = ./preset-firewall.nix;
  godel = ./godel;
  secrets = ./secrets;
  desktop = ./desktop;
  netflow = ./netflow;
  services = ./services;
  bootloader = ./bootloader.nix;
}
