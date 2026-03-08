{
  stdenv,
  fetchurl,
}:

let
  version = "0.1.3";

  srcs = {
    x86_64-linux = {
      url = "https://github.com/RMTT/sb-lite/releases/download/v${version}/sblite-amd64-linux.tar.gz";
      sha256 = "14ya6fm7gbq4grbzy808dln9mk6kxw300bnfdzz8h81ljrxfyvb0";
      binaryName = "sblite-amd64-linux";
    };
    aarch64-linux = {
      url = "https://github.com/RMTT/sb-lite/releases/download/v${version}/sblite-arm64-linux.tar.gz";
      sha256 = "0sfqglqdz87cy8fib3iy80p7ciq8rwww3hmnj7f1knakm7i747ck";
      binaryName = "sblite-arm64-linux";
    };
  };

  sys =
    srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

in
stdenv.mkDerivation {
  pname = "sblite";
  inherit version;

  src = fetchurl {
    inherit (sys) url sha256;
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm755 ${sys.binaryName} $out/bin/sblite

    runHook postInstall
  '';

  meta = {
    description = "A lightweight proxy client based on sing-box";
    homepage = "https://github.com/RMTT/sb-lite";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "sblite";
  };
}
