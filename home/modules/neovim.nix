{ pkgs, lib, ... }:
let
  fromGitHub =
    ref: rev: repo:
    pkgs.vimUtils.buildVimPlugin {
      pname = "${lib.strings.sanitizeDerivationName repo}";
      version = ref;
      src = builtins.fetchGit {
        url = "https://github.com/${repo}.git";
        ref = ref;
        rev = rev;
      };
    };
in
{
  programs.neovim =
    let
      configPath = "${../config/nvim}/lua";
    in
    {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
      withPython3 = true;
      withNodeJs = true;
      extraLuaConfig = ''
        package.path = package.path .. ";${../config/nvim}/?.lua;${configPath}/?.lua;${configPath}/?/init.lua;${configPath}/lsp/?.lua;${configPath}/plugins/?.lua"
        require('startup')('${../config/nvim}')
      '';
      plugins = with pkgs.vimPlugins; [
        lazy-nvim
      ];
      # install luanguage servers
      extraPackages = with pkgs; [
        ripgrep
        lua-language-server
        ruff
        pyright
        cmake-language-server
        tree-sitter
        clang-tools
        efm-langserver
        gopls
        black
        shellcheck
        nodePackages.bash-language-server
        shfmt
        nixd
        nixfmt
      ];
    };
}
