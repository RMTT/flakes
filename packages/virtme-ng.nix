{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  rustPlatform,
  pkg-config,
  qemu,
  virtiofsd,
}:

stdenv.mkDerivation rec {
  pname = "virtme-ng";
  version = "1.40";

  src = fetchFromGitHub {
    owner = "arighi";
    repo = "virtme-ng";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
  };

  nativeBuildInputs = [
    pkg-config
    python3
    rustPlatform.cargoSetupHook
    rustPlatform.rust.rustc
    rustPlatform.rust.cargo
  ];

  buildInputs = [
    python3
    qemu
    virtiofsd
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src pname version;
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
  };

  # Assuming standard build procedure based on typical Rust/Python projects
  buildPhase = ''
    cargo build --release
    python3 setup.py build
  '';

  installPhase = ''
    python3 setup.py install --root=$out --prefix=/
    install -Dm755 target/release/virtme-ng $out/bin/virtme-ng
  '';

  meta = {
    description = "Quickly build and run kernels inside a virtualized snapshot of your live system";
    homepage = "https://github.com/arighi/virtme-ng";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
