{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "zsh-patina";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "michel-kraemer";
    repo = "zsh-patina";
    rev = version;
    hash = "sha256-WVlv+bYFTQ3RG3m2NnG13kMoslXzcPr8CpFWwAOcNBA=";
  };

  cargoHash = "sha256-A946sab9GDBdoNAWH7AN10lEhHNnHnCnNzQgnEcQ8QI=";

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
