{ config, lib, ... }:
with lib;
mkIf (config.nixpkgs.system == "aarch64-darwin") (
  let
    taps = [ ];

    brews = [
      "koekeishiya/formulae/skhd"
      "kubernetes-cli"
      "node"
      "gitui"
      "anomalyco/tap/opencode"
    ];

    casks = [
      "yubico-authenticator"
      "obsidian"
      "telegram"
      "tailscale-app"
      "wechat"
      "iterm2" # for drop-down term(via hotkey profile)
      "kicad"
      "PlayCover/playcover/playcover-community"
      "zotero"
      "firefox"
      "bitwarden"
      "iina"
      "google-drive"
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
