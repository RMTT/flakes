{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "zsh-patina";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "michel-kraemer";
    repo = "zsh-patina";
    rev = version;
    hash = "sha256-uJlJCVe3jt4xIZAb5TMgkcva2WVKBQ2zVavHmpvG26s=";
  };

  cargoHash = "sha256-ISp1im8yJ+V8nV3H33Yzn+2X2tZgX0UArFLVmvKJuoA=";

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
