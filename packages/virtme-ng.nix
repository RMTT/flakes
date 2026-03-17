{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  rustPlatform,
  pkg-config,
  qemu,
  virtiofsd,
  rustc,
  cargo,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "virtme-ng";
  version = "1.40";

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
    python3Packages.python
    python3Packages.setuptools
    rustPlatform.cargoSetupHook
    rustc
    cargo
    makeWrapper
  ];

  buildInputs = [
    python3Packages.python
    python3Packages.argcomplete
    qemu
    virtiofsd
  ];

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
    sed -i 's|"/usr/share/bash-completion/completions"|"share/bash-completion/completions"|g' setup.py
    sed -i 's|"/usr/share/man/man1"|"share/man/man1"|g' setup.py
    sed -i 's|name="virtme-ng"|name="virtme_ng"|g' setup.py
    sed -i 's|"virtme-ng = virtme_ng.run:main"|"virtme_ng = virtme_ng.run:main"|g' setup.py
    rm Makefile
  '';

  buildPhase = ''
    python3 setup.py build
  '';

  installPhase = ''
    python3 setup.py install --prefix=$out
  '';

  # Wrap the console scripts to set PYTHONPATH
  postInstall = ''
    # Find the egg-info directory dynamically
    for f in $out/lib/python3.13/site-packages/*.egg-info; do
      if [ -d "$f" ]; then
        mv "$f" "$out/lib/python3.13/site-packages/virtme-ng-1.40.dist-info"
      fi
    done
    # Patch the console scripts
    for script in $out/bin/*; do
      sed -i 's|virtme-ng|virtme_ng|g' "$script"
      sed -i 's|virtme_ng==1.40|virtme-ng==1.40|g' "$script"
      wrapProgram "$script" --set PYTHONPATH "$PYTHONPATH:$out/lib/python3.13/site-packages"
    done
  '';

  meta = {
    description = "Quickly build and run kernels inside a virtualized snapshot of your live system";
    homepage = "https://github.com/arighi/virtme-ng";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
