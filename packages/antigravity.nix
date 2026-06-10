{
  stdenv,
  fetchurl,
  copyDesktopItems,
  makeDesktopItem,
  asar,
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
  version = "100.0.0-5871373990625280";

  src = fetchurl {
    url = "https://storage.googleapis.com/antigravity-public/antigravity-hub/${version}/linux-x64/Antigravity.tar.gz";
    hash = "sha256-+88Vz9wR/IFuDK8EXqB6bNaUutI5vv0JSGBmHyjtLUY=";
  };

  desktopItem = makeDesktopItem {
    name = "antigravity";
    desktopName = "Antigravity";
    exec = "antigravity %U";
    icon = "antigravity";
    terminal = false;
    type = "Application";
    startupWMClass = "Antigravity";
    categories = [ "Development" "Utility" ];
    comment = "Antigravity Hub client application";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
    asar
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

  desktopItems = [ desktopItem ];

  sourceRoot = "Antigravity-x64";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/antigravity
    cp -r * $out/opt/antigravity/

    # Create the bin wrapper
    mkdir -p $out/bin
    makeWrapper $out/opt/antigravity/antigravity $out/bin/antigravity \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libnotify libappindicator-gtk3 ]}:$out/opt/antigravity

    # Extract and install icon from app.asar
    asar extract-file resources/app.asar icon.png icon.png
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp icon.png $out/share/icons/hicolor/256x256/apps/antigravity.png

    runHook postInstall
  '';

  meta = {
    description = "Antigravity Hub client application";
    homepage = "https://storage.googleapis.com/antigravity-public/antigravity-hub/index.html";
    platforms = [ "x86_64-linux" ];
    mainProgram = "antigravity";
  };
}
