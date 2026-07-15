{
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  lib,
  writeShellScript,
  curl,
  jq,
  gnused,
  nix,
  python3,
  nix-update,
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
  version = "1.18.1";

  srcs = {
    x86_64-linux = fetchurl {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-desktop-linux-amd64.deb";
      hash = "sha256-CyEzGdPFGjL6He2euDMQFas0Fgr7z9BFTkF7QS849+E=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-desktop-linux-arm64.deb";
      hash = "sha256-s0Ynf3fGbi18+SPndBUjyvBcvb91ohe5ejY5QvVJXjY=";
    };
  };

  src =
    srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  desktopItem = makeDesktopItem {
    name = "opencode-desktop";
    desktopName = "OpenCode";
    exec = "opencode-desktop %U";
    icon = "opencode-desktop";
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
  autoPatchelfIgnoreMissingDeps = [
    "libc.musl-x86_64.so.1"
    "libc.musl-aarch64.so.1"
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/OpenCode
    cp -r opt/OpenCode/* $out/opt/OpenCode/

    # Create the bin wrapper
    mkdir -p $out/bin
    makeWrapper $out/opt/OpenCode/ai.opencode.desktop $out/bin/opencode-desktop \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libGL
          mesa
          libnotify
        ]
      }:$out/opt/OpenCode

    # Install icons
    for size in $(find usr/share/icons -mindepth 2 -maxdepth 2 -type d -printf '%f\n' 2>/dev/null); do
      if [ -f "usr/share/icons/hicolor/$size/apps/ai.opencode.desktop.png" ]; then
        mkdir -p "$out/share/icons/hicolor/$size/apps"
        cp "usr/share/icons/hicolor/$size/apps/ai.opencode.desktop.png" \
           "$out/share/icons/hicolor/$size/apps/opencode-desktop.png"
      fi
    done

    runHook postInstall
  '';

  passthru.updateScript = writeShellScript "update-opencode-desktop" ''
    set -euo pipefail
    latest_version=$(${curl}/bin/curl -sL https://api.github.com/repos/anomalyco/opencode/releases/latest | ${jq}/bin/jq -r '.tag_name')
    latest_version="''${latest_version#v}"
    exec ${nix-update}/bin/nix-update --version "$latest_version" --flake "''${UPDATE_NIX_ATTRPATH:-opencode-desktop}"
  '';

  meta = {
    description = "OpenCode AI desktop application";
    homepage = "https://opencode.ai";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "opencode-desktop";
  };
}
