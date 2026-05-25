{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  lib,
  alsa-lib,
  at-spi2-atk,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libGL,
  libappindicator-gtk3,
  libdrm,
  libnotify,
  libpulseaudio,
  libuuid,
  vulkan-loader,
  libxshmfence,
  mesa,
  nspr,
  nss,
  pango,
  systemd,
  xdg-utils,
  libx11,
  libxscrnsaver,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxrender,
  libxtst,
  libxcb,
}:

let
  pname = "antigravity";
  version = "2.0.6-5413878570549248";

  src = fetchurl {
    url = "https://storage.googleapis.com/antigravity-public/antigravity-hub/${version}/linux-x64/Antigravity.tar.gz";
    hash = "sha256-rR4EU1FJsHwnAw6x6tQPTv2jiMs5AgvLuazN+0nkTMU=";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libGL
    libappindicator-gtk3
    libdrm
    libnotify
    libpulseaudio
    libuuid
    vulkan-loader
    libxshmfence
    mesa
    nspr
    nss
    pango
    systemd
    libx11
    libxscrnsaver
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxtst
    libxcb
  ];

  sourceRoot = "Antigravity-x64";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/antigravity
    cp -r * $out/opt/antigravity/

    # Create the bin wrapper
    mkdir -p $out/bin
    makeWrapper $out/opt/antigravity/antigravity $out/bin/antigravity \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --prefix LD_LIBRARY_PATH : $out/opt/antigravity

    runHook postInstall
  '';

  meta = {
    description = "Antigravity Hub client application";
    homepage = "https://storage.googleapis.com/antigravity-public/antigravity-hub/index.html";
    platforms = [ "x86_64-linux" ];
    mainProgram = "antigravity";
  };
}
