{
  stdenv,
  fetchFromGitHub,
  lib,
}:

stdenv.mkDerivation rec {
  pname = "impeccable";
  version = "2026-03-21";

  src = fetchFromGitHub {
    owner = "pbakaus";
    repo = "impeccable";
    rev = "cd919235c1c16d29903dc73f87f42ab85db41891";
    hash = "sha256-i3aSdIiRBlvLufy5yRhma05lEzikmmfQRQTSi2dPkic=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -r source/skills/. "$out/skills"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Impeccable agent skills";
    homepage = "https://github.com/pbakaus/impeccable";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
