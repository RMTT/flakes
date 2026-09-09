{ pkgs, ... }: {
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    enableZshIntegration = true;
    settings = {
      font-family = "FiraCode Nerd Font Mono";
      keybind = [
        "global:alt+grave_accent=toggle_quick_terminal"
      ];
    };
  };
}
