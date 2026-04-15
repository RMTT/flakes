{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ansible
    colmena
    (pkgs.wrapHelm pkgs.kubernetes-helm {
      plugins = with pkgs.kubernetes-helmPlugins; [
        helm-secrets
      ];
    })
  ];

  programs.docker-cli = {
    enable = true;
    settings = {
      "detachKeys" = "ctrl-x";
    };
  };
}
