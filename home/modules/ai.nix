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
  xdg.configFile."opencode/opencode.json".source = ../config/opencode/opencode.json;
  xdg.configFile."opencode/AGENTS.md".source = ../config/agents/AGENTS.md;
  home.file.".gemini/GEMINI.md".source = ../config/agents/AGENTS.md;
  home.file.".gemini/antigravity-cli/mcp_config.json".source = ../config/agents/mcp_config.json;

  home.packages = with pkgs; [ uv ];

  programs.zsh.initContent = ''
    export MCP_CONTEXT7="$(cat ${config.sops.secrets.mcp_context7.path})"
    export MCP_EXA="$(cat ${config.sops.secrets.mcp_exa.path})"
    export MCP_GITHUB="$(cat ${config.sops.secrets.mcp_github.path})"
  '';
}
