{ lib, config, ... }:
with lib;
{
  options.services.gravity = {
    enable = mkEnableOption "gravity overlay network, next generation";
  };

  config = {

  };
}
