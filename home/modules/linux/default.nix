{ pkgs, ... }:
{
  imports = [
    ./niri.nix
    ./fonts.nix
    ./runner.nix
  ];

  gtk = {
    enable = true;
    theme = {
      name = "Dracula";
      package = pkgs.dracula-theme;
    };
    iconTheme = {
      name = "Numix";
      package = pkgs.numix-icon-theme;
    };
  };
  home.packages = with pkgs; [ gitui ];

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Adwaita";
    size = 24;
    package = pkgs.adwaita-icon-theme;
  };

  # make npm install -g works
  programs.zsh.initContent = ''
    export PATH=~/.npm-packages/bin:$PATH
  '';
  home.file.".npmrc".text = ''
    prefix = ''${HOME}/.npm-packages
  '';

  xresources.properties = {
    "Xft.dpi" = 120;
  };
}
