{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "zsh-patina";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "michel-kraemer";
    repo = "zsh-patina";
    rev = version;
    hash = "sha256-M14IeK+Nsst+6RK6ayhq37YSoFPVptNqE9blVHDI1YM=";
  };

  cargoHash = "sha256-4Meb4BDV/Um8/YMA5DkeNDcgCMS5cA8olKhOIq9coIU=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
    ];
  };
  meta = with lib; {
    description = "A blazingly fast Zsh plugin performing syntax highlighting of your command line while you type";
    homepage = "https://github.com/michel-kraemer/zsh-patina";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "patina";
  };
}
