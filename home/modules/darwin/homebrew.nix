{ config, lib, ... }:
lib.mkIf (config.nixpkgs.system == "aarch64-darwin") (
  let
    taps = [
      "Sanyam-G/switch"
    ];

    brews = [
      "ykman"
    ];

    casks = [
      "hammerspoon"
      "google-chrome"
      "bitwarden"
      "font-fira-code-nerd-font"
      "tailscale-app"
      "notion"
      "zotero"
      "opencode-desktop"
      "antigravity"
      "Sanyam-G/switch/switch" # for switch windows in current Space
      "appcleaner"
      "omniwm"
    ];

  in
  {
    home.sessionPath = [ "/opt/homebrew/bin" ];

    home.sessionVariables = {
      HOMEBREW_BUNDLE_FILE = "~/.Brewfile";
    };
    home.file.".Brewfile" = {
      text =
        (lib.concatMapStrings (
          tap:
          ''tap "''
          + tap
          + ''
            "
          ''

        ) taps)
        + (lib.concatMapStrings (
          brew:
          ''brew "''
          + brew
          + ''
            "
          ''

        ) brews)
        + (lib.concatMapStrings (
          cask:
          ''cask "''
          + cask
          + ''
            "
          ''

        ) casks);
    };
  }
)
