# Description
My infrastructure configuration via NixOS and kubernetes for my homelab

## Garnix status
[![built with garnix](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fgarnix.io%2Fapi%2Fbadges%2FRMTT%2Fmachines%3Fbranch%3Dmain)](https://garnix.io)

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
