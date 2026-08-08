{ pkgs, ... }: {
  home.packages = with pkgs; [
    gitui
    jq
    zellij
    nh
    kubectl
  ];
}
