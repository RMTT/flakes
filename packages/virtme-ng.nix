{
  lib,
  python3Packages,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  qemu,
  virtiofsd,
  rustc,
  cargo,
  flex,
  bison,
  bc,
}:

python3Packages.buildPythonApplication rec {
  pname = "virtme-ng";
  version = "1.40";

  pyproject = true;
  build-system = [ python3Packages.setuptools ];

  src = fetchFromGitHub {
    owner = "arighi";
    repo = "virtme-ng";
    rev = "v${version}";
    hash = "sha256-5vJ+wyCA0XKXtEzEGim1OoTBDFTS2BjJSIzkLvTYHn8=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src pname version;
    hash = "sha256-3+MDf6pescqPnsQBOODZJ7ic2tqxh5LPvHIMouUkhjI=";
    sourceRoot = "${src.name}/virtme_ng_init";
  };

  nativeBuildInputs = [
    pkg-config
    python3Packages.setuptools
    python3Packages.argparse-manpage
    rustPlatform.cargoSetupHook
    rustc
    cargo
  ];

  propagatedBuildInputs = [
    python3Packages.argcomplete
    python3Packages.requests
    qemu
    virtiofsd
    flex
    bison
    bc
  ];

  # Use cargoSetupHook properly
  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
    sed -i 's|"/usr/share/bash-completion/completions"|"share/bash-completion/completions"|g' setup.py
    sed -i 's|"/usr/share/man/man1"|"share/man/man1"|g' setup.py
    rm Makefile
  '';

  # Disable cargo hook during unpack to prevent issues
  dontCargoSetupPostUnpackHook = true;
  cargoRoot = ".";

  # virtme_ng_init gets built inside setup.py (which invokes cargo).
  # We should ensure RUSTFLAGS and others are set up properly,
  # or rely on cargoSetupHook.

  meta = {
    description = "Quickly build and run kernels inside a virtualized snapshot of your live system";
    homepage = "https://github.com/arighi/virtme-ng";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
