{ pkgs, config, ... }:
{
  imports = [
    # ./niri.nix
    ./fonts.nix
    # ./runner.nix
  ];

  # make npm install -g works
  programs.zsh.initContent = ''
    export PATH=~/.npm-packages/bin:$PATH
  '';
  home.file.".npmrc".text = ''
    prefix = ''${HOME}/.npm-packages
  '';

  services.easyeffects = {
    enable = true;
  };
}
