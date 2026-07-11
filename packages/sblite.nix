{
  stdenv,
  fetchurl,
  nix-update-script,
}:

let
  version = "0.1.6";

  srcs = {
    x86_64-linux = {
      url = "https://github.com/RMTT/sb-lite/releases/download/v${version}/sblite-amd64-linux.tar.gz";
      sha256 = "sha256-rnPfDHxKslSBCeYMMUPIyZaAxlo2qxRsN4L1AReIv98=";
      binaryName = "sblite-amd64-linux";
    };
    aarch64-linux = {
      url = "https://github.com/RMTT/sb-lite/releases/download/v${version}/sblite-arm64-linux.tar.gz";
      sha256 = "1w3wvahg6vx8dbi8v6bk9i0kfv1ind92f4k96nasijd0z0fafv98";
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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
    ];
  };
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
