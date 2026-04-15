{ pkgs, lib, ... }:
{
  xdg.configFile."nvim/lua".source = ../config/nvim/lua;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    withPython3 = true;
    withNodeJs = true;
    initLua = builtins.readFile ../config/nvim/init.lua;
    # install luanguage servers
    extraPackages = with pkgs; [
      ripgrep
      lua-language-server
      ruff
      ty
      cmake-language-server
      tree-sitter
      clang-tools
      efm-langserver
      typescript-language-server
      vscode-langservers-extracted
      gopls
      black
      shellcheck
      bash-language-server
      shfmt
      nixd
      nixfmt
      terraform-ls
      # for markdown render
      (python3.withPackages (ps: with ps; [ pylatexenc ]))
    ];
  };
}
