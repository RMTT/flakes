{ ... }:
{
  imports = [
    ./services/pppoe.nix
    ./services/udp2raw.nix
    ./services/socat.nix
    ./services/aronet.nix
    ./services/gost.nix
    ./services/singbox.nix
  ];
}
