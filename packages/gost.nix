{ buildGoModule, fetchFromGitHub }:
let
  version = "3.1.0";
in
buildGoModule {
  pname = "gost";
  inherit version;

  src = fetchFromGitHub {
    owner = "go-gost";
    repo = "gost";
    rev = "v${version}";
    hash = "sha256-4ZfGxhXespaZNspvbwZ/Yz2ncqtY3wxJPQsqVILayao=";
  };

  vendorHash = "sha256-lWuLvYF9Sl+k8VnsujvRmj7xb9zst+g//Gkg7VwtWkg=";

  meta = {
    mainProgram = "gost";
  };
}
