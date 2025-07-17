{ fetchFromGitHub, stdenv }:
stdenv.mkDerivation {
  pname = "gost-ui";
  version = "2025-06-27";
  src = fetchFromGitHub {
    owner = "go-gost";
    repo = "gost-ui";
    rev = "c6eb6b71e0b71b0d1cf14be8091811efc8f58887";
    hash = "sha256-VVozERZkFk37AowAOmCoO/NowBIsbvQRfeW8Pc5/rv0=";
  };

  installPhase = ''
    mkdir -p $out
    cp -r ./* $out
  '';
  dontBuild = true;
}
