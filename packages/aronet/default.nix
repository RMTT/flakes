{ stdenv, fetchFromGitHub, meson, ncurses, readline, ninja, automake, autoconf
, libtool, gnumake, pkg-config, gettext, perl, gperf, flex, bison, openssl, git
, python3, systemd, cacert, iproute2, rustc, cargo, rustPlatform }:
stdenv.mkDerivation rec {
  pname = "aronet";
  version = "v0.1-beta1";
  buildInputs = [ iproute2 openssl ncurses readline gettext systemd ];
  nativeBuildInputs = [
    ninja
    automake
    autoconf
    pkg-config
    git
    libtool
    gperf
    bison
    flex
    gettext
    python3
    gnumake
    perl
    meson
    rustPlatform.cargoSetupHook
    rustc
    cargo
  ];

  postPatch = ''
    patchShebangs aronet/build.sh
    patchShebangs subprojects/bird/build.sh
    patchShebangs subprojects/strongswan/build.sh
  '';

  mesonBuildType = "release";
  cargoRoot = "aronet";
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    sourceRoot = "${src.name}/aronet";
    hash = "sha256-QWPdASLP2ycu/lqB7OkrEukH29qItCOw4u1Seuy02yA=";
  };

  src = fetchFromGitHub {
    owner = "RMTT";
    repo = "aronet";
    rev = "aed06830e5a2586298ec7ea86544d9cebc49d8d9";
    hash = "sha256-QMXanx7jf6kjd/eLLHlPEZfTzUknrxUdILe/1LIhMbk=";
    nativeBuildInputs = [ git meson cacert ];
    postFetch = ''
      cd "$out"
      for prj in subprojects/*.wrap; do
        meson subprojects download "$(basename "$prj" .wrap)"
        rm -rf subprojects/$(basename "$prj" .wrap)/.git
      done
    '';
  };
}
