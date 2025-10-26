{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
{
  imports = [
    ./homebrew.nix
    ./skhd.nix
    ../kitty.nix
    ./secrets.nix
  ];

  config = {
    programs.home-manager.enable = lib.mkForce false;

    home.packages = with pkgs; [
      nerd-fonts.fira-code
      sshuttle
      lima # for running x86 vms and containers
      htop
      nixos-rebuild
      wget
      kitty
      age

      # dev tools
      cmake
      autoconf
      automake
      glibtool
      pkg-config
      gettext
      perl
      gperf
      flex
      bison
      rustup
      bear
      sops

      (pkgs.python3.withPackages (python-pkgs: [ ]))
    ];

    programs.zsh.initContent = ''
      export ANTHROPIC_BASE_URL="$(cat ${config.sops.secrets.claude_base_url.path})"
      export ANTHROPIC_AUTH_TOKEN="$(cat ${config.sops.secrets.claude_token.path})"
      export CLAUDE_CODE_ENABLE_TELEMETRY=0
      export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
      export DISABLE_ERROR_REPORTING=1
      export DISABLE_TELEMETRY=1
    '';
  };
}
