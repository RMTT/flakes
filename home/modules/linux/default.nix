{ pkgs, config, ... }:
{
  imports = [
    ./niri.nix
    ./fonts.nix
    ./runner.nix
  ];

  # color theme is managed by noctalia
  gtk = {
    enable = true;
    iconTheme = {
      name = "Numix";
      package = pkgs.numix-icon-theme;
    };
    gtk4.theme = config.gtk.theme;
  };

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
