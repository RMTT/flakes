{
  buildGo125Module,
  fetchzip,
}:

buildGo125Module (finalAttrs: {
  pname = "traefik";
  version = "3.7.1";

  src = fetchzip {
    url = "https://github.com/traefik/traefik/releases/download/v${finalAttrs.version}/traefik-v${finalAttrs.version}.src.tar.gz";
    hash = "sha256-LP4V70QvPmeafaArt8AWGkOj9dsKkEPE9dCulP+SmFw=";
    stripRoot = false;
  };

  vendorHash = "sha256-UHsgq6B3h6z/TZZpZi6o/KzahBDTiQszFikbpUvH80s=";

  proxyVendor = true;

  buildPhase = ''
    runHook preBuild
    GOOS= GOARCH= CGO_ENABLED= go build -ldflags="-s -w" -o traefik ./cmd/traefik
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 traefik $out/bin/traefik
    runHook postInstall
  '';

  meta = {
    description = "Modern reverse proxy";
    homepage = "https://traefik.io";
    changelog = "https://github.com/traefik/traefik/raw/v${finalAttrs.version}/CHANGELOG.md";
    mainProgram = "traefik";
  };
})
