{
  stdenv,
  fetchFromGitHub,
  lib,
}:

stdenv.mkDerivation rec {
  pname = "superpowers";
  version = "main";

  src = fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    rev = "v5.0.2";
    hash = "sha256-AyRGXwWI9xHGeHw9vD64cnV19txR/lOtxudcHnbV75I=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r * $out/
    cp -r .opencode $out/

    runHook postInstall
  '';

  meta = with lib; {
    description = "A complete software development workflow for your coding agents";
    homepage = "https://github.com/obra/superpowers";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
