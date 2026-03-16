{
  stdenv,
  fetchurl,
}:

let
  version = "0.1.3";

  srcs = {
    x86_64-linux = {
      url = "https://github.com/RMTT/sb-lite/releases/download/v${version}/sblite-amd64-linux.tar.gz";
      sha256 = "09407w48vsj3nqdbgh8kmq9xpzxfqk5iddy0cmjglh44pjsygh67";
      binaryName = "sblite-amd64-linux";
    };
    aarch64-linux = {
      url = "https://github.com/RMTT/sb-lite/releases/download/v${version}/sblite-arm64-linux.tar.gz";
      sha256 = "1x4f3ybnmpp69a9q4vaj7awgmcrd8pjjlww1bmxa8v3czvifq2a9";
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
