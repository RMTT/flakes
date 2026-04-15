{
  config,
  pkgs,
  lib,
  ...
}:
{
  sops.secrets.mcp_context7 = {
    mode = "0400";
  };
  sops.secrets.mcp_exa = {
    mode = "0400";
  };
  sops.secrets.mcp_github = {
    mode = "0400";
  };
  xdg.configFile."opencode/opencode.jsonc".source = ../config/opencode/opencode.jsonc;
  xdg.configFile."opencode/AGENTS.md".source = ../config/opencode/AGENTS.md;

  home.packages = with pkgs; [ uv ];

  programs.zsh.initContent = ''
    export MCP_CONTEXT7="$(cat ${config.sops.secrets.mcp_context7.path})"
    export MCP_EXA="$(cat ${config.sops.secrets.mcp_exa.path})"
    export MCP_GITHUB="$(cat ${config.sops.secrets.mcp_github.path})"
  '';
}
