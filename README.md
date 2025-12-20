# Description
My infrastructure configuration via NixOS and kubernetes for my homelab

## Nixos

### Partition

Use partition label to identify partitions

### Install

`nixos-install/nixos-rebuild --flake github:RMTT/machines#{machine name}`

## macOS

Required apps:
+ `nix`
+ `homebrew`
+ `home-manager`

Configurations steps:
+ `home-manager` switch --flake .#darwin
+ `brew` bundle --global
+ configure rectangle app
+ configure skhd app
