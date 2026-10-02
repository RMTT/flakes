{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.machine.development;
in
{
  options.machine.development = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "install development tools";
      default = false;
    };
  };
  config = lib.mkIf cfg.enable {
    # add development tools
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
    environment.systemPackages = with pkgs; [
      nodejs # typescript and javascript
      uv # python
      zellij
      qemu
      clang
      gdb
      cmake
      gnumake
      clang-tools
      pkg-config
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
      mystmd
      nerdctl
      act
      virtme-ng
      gitui
      terraform
      neovide
      rustup
      dix
      fluxcd
    ];
  };
}
