{ config, lib, ... }:
with lib;
mkIf (config.nixpkgs.system == "aarch64-darwin") (
  let
    taps = [ ];

    brews = [
    ];

    casks = [
      "google-chrome"
      "bitwarden"
      "flashspace"
      "font-fira-code-nerd-font"
      "tailscale-app"
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
