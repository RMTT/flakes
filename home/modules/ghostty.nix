{ pkgs, ... }: {
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    enableZshIntegration = true;
    settings = {
      font-family = "FiraCode Nerd Font Mono";
      keybind = [
        "global:cmd+grave_accent=toggle_quick_terminal"
      ];
    };
  };
}
