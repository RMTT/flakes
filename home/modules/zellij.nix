{ ... }: {
  programs.zellij = {
    enable = true;

    extraConfig = ''
      keybinds {
        shared_except "locked" {
          unbind "Ctrl n"
          unbind "Ctrl p"
        }

        normal {
          bind "Ctrl w" { SwitchToMode "Pane"; }
          bind "Ctrl i" { SwitchToMode "Resize"; }
        }
      }
    '';
  };
}
