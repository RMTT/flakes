{
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
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
  libglvnd,
  libappindicator-gtk3,
  libdrm,
  libnotify,
  libpulseaudio,
  libsecret,
  libuuid,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  systemd,
  xdg-utils,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
}:

let
  pname = "opencode-desktop";
  version = "1.17.0";

  src = fetchurl {
    url = "https://opencode.ai/zh/download/stable/linux-x64-deb";
    hash = "sha256-42ZSkLsj+uoYDXzAmcPVSRS8uCwJMkWDEF5KSartSMo=";
    name = "opencode-desktop-${version}-linux-amd64.deb";
  };

  desktopItem = makeDesktopItem {
    name = "OpenCode";
    desktopName = "OpenCode";
    exec = "opencode-desktop %U";
    icon = "OpenCode";
    terminal = false;
    type = "Application";
    startupWMClass = "OpenCode";
    mimeTypes = [ "x-scheme-handler/opencode" ];
    categories = [ "Development" ];
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
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
    libglvnd
    libappindicator-gtk3
    libdrm
    libnotify
    libpulseaudio
    libsecret
    libuuid
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemd
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
  ];

  desktopItems = [ desktopItem ];

  # The deb bundles both glibc and musl variants of native node modules.
  # The musl variants are unused on NixOS, so ignore their libc dependency.
  autoPatchelfIgnoreMissingDeps = [ "libc.musl-x86_64.so.1" ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/OpenCode
    cp -r opt/OpenCode/* $out/opt/OpenCode/

    # Create the bin wrapper
    mkdir -p $out/bin
    makeWrapper $out/opt/OpenCode/@opencode-aidesktop $out/bin/opencode-desktop \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libglvnd libGL ]}:$out/opt/OpenCode

    # Install icons
    for size in $(find usr/share/icons -mindepth 2 -maxdepth 2 -type d -printf '%f\n' 2>/dev/null); do
      if [ -f "usr/share/icons/hicolor/$size/apps/@opencode-aidesktop.png" ]; then
        mkdir -p "$out/share/icons/hicolor/$size/apps"
        cp "usr/share/icons/hicolor/$size/apps/@opencode-aidesktop.png" \
           "$out/share/icons/hicolor/$size/apps/OpenCode.png"
      fi
    done

    runHook postInstall
  '';

  meta = {
    description = "OpenCode AI desktop application";
    homepage = "https://opencode.ai";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "opencode-desktop";
  };
}
