{ ... }:
{
  imports = [
    ./udp2raw.nix
    ./socat.nix
    ./aronet.nix
    ./gost.nix
    ./singbox.nix
    ./ssserver.nix
    ./sblite.nix
  ];
}
