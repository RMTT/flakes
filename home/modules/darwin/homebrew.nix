{ config, lib, ... }:
with lib;
mkIf (config.nixpkgs.system == "aarch64-darwin") (
  let
    taps = [ ];

    brews = [
    ];

    casks = [
      "steam"
      "hammerspoon"
      "google-chrome"
      "google-drive"
      "bitwarden"
      "font-fira-code-nerd-font"
      "tailscale-app"
      "notion"
      "zotero"
      "opencode-desktop"
      "antigravity"
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
