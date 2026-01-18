{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.machine.development;
in
with lib;
{
  options.machine.development = {
    enable = mkOption {
      type = types.bool;
      description = "install development tools";
      default = false;
    };
  };
  config = mkIf cfg.enable {
    # add development tools
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
    environment.systemPackages = with pkgs; [
      gcc
      gdb
      jdk
      cmake
      gradle
      gnumake
      google-cloud-sdk
      nodejs
      clang-tools
      pkg-config
      pgcli
      yq-go
      gh
      distrobox
      go
      tldr
      trace-cmd
      kubernetes
      kubernetes-helm
      kustomize
      hugo
      uv
      mystmd
    ];

  };
}
