{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "zsh-patina";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "michel-kraemer";
    repo = "zsh-patina";
    rev = "1.7.0";
    hash = "sha256-sPlIT3UHtq+5+bpfrSPPfVXTdmqjEq+6k9tPShhG7h0=";
  };

  cargoHash = "sha256-j2MwEwQhSCUCwANAxr0aZjJ9iS0cGzRRttfK8LONEpg=";

  meta = with lib; {
    description = "A blazingly fast Zsh plugin performing syntax highlighting of your command line while you type";
    homepage = "https://github.com/michel-kraemer/zsh-patina";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "patina";
  };
}
