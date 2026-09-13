{ config, lib, ... }:
with lib;
mkIf (config.nixpkgs.system == "aarch64-darwin") (
  let
    taps = [
      "Sanyam-G/switch"
    ];

    brews = [
      "ykman"
    ];

    casks = [
      "steam"
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
      "cloudmounter"
    ];

  in
  with lib;
  {
    home.sessionPath = [ "/opt/homebrew/bin" ];

    home.sessionVariables = {
      HOMEBREW_BUNDLE_FILE = "~/.Brewfile";
    };
    home.file.".Brewfile" = {
      text =
        (concatMapStrings (
          tap:
          ''tap "''
          + tap
          + ''
            "
          ''

        ) taps)
        + (concatMapStrings (
          brew:
          ''brew "''
          + brew
          + ''
            "
          ''

        ) brews)
        + (concatMapStrings (
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
