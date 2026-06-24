{ pkgs, git-hooks-nix }:
git-hooks-nix.lib.${pkgs.system}.run {
  src = ./.;
  hooks = {
    sops-check = {
      enable = true;
      name = "sops-check";
      description = "Check if files under secrets directories are encrypted by sops";
      entry = "${pkgs.writeShellScript "sops-check" ''
        exit_code=0
        for file in "$@"; do
          # Check if the file is default.nix
          if [ "$(basename "$file")" = "default.nix" ]; then
            continue
          fi
          
          # Check if the file actually exists
          if [ ! -f "$file" ]; then
            continue
          fi

          # Use sops filestatus to detect if it is encrypted.
          if ! ${pkgs.sops}/bin/sops filestatus "$file" 2>/dev/null | grep -q '"encrypted":true'; then
            echo "Error: File '$file' is under a secrets directory but is not sops-encrypted!"
            exit_code=1
          fi
        done
        exit $exit_code
      ''}";
      files = "(^|/)secrets/.*$";
      excludes = [ "default\\.nix$" ];
    };
  };
}
