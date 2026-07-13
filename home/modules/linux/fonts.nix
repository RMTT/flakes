{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
mkIf (config.nixpkgs.system == "x86_64-linux") {
  home.packages = with pkgs; [
    wqy_zenhei
    noto-fonts
    sarasa-gothic
    noto-fonts-color-emoji
    nerd-fonts.fira-code
    inter
    roboto
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      serif = [
        "Noto Serif CJK SC" # Simplified Chinese
        "Noto Serif CJK TC" # Traditional Chinese
        "Noto Serif CJK HK"
        "Noto Serif CJK JP" # Japanese
        "Noto Serif CJK KR" # Korean

        "Noto Serif" # fallback
      ];
      sansSerif = [
        "Inter"

        "Sarasa Gothic SC"
        "Sarasa Gothic TC"
        "Sarasa Gothic HC"
        "Sarasa Gothic J"
        "Sarasa Gothic K"

        "Noto Sans" # fallback
      ];
      monospace = [
        "Sarasa Mono SC"
        "Sarasa Mono TC"
        "Sarasa Mono HC"
        "Sarasa Mono J"
        "Sarasa Mono K"

        "Noto Sans Mono" # fallback
      ];
    };
  };
}
