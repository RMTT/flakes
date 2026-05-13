{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ansible
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
