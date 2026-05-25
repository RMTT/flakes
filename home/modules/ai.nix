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
  sops.templates.antigravity-mcp = {
    path = "${config.home.homeDirectory}/.gemini/config/mcp_config.json";
    content = ''
      {
        "mcpServers": {
          "github": {
            "serverUrl": "https://api.githubcopilot.com/mcp/",
            "headers": {
              "Authorization": "Bearer ${config.sops.placeholder.mcp_github}"
            }
          },
          "context7": {
            "command": "npx",
            "args": [
              "-y",
              "@upstash/context7-mcp",
              "--api-key",
              "${config.sops.placeholder.mcp_context7}"
            ]
          }
        }
      }

    '';
  };

  xdg.configFile."opencode/opencode.json".source = ../config/agents/opencode/opencode.json;
  xdg.configFile."opencode/AGENTS.md".source = ../config/agents/AGENTS.md;
  home.file.".gemini/GEMINI.md".source = ../config/agents/AGENTS.md;

  programs.zsh.initContent = ''
    export MCP_CONTEXT7="$(cat ${config.sops.secrets.mcp_context7.path})"
    export MCP_EXA="$(cat ${config.sops.secrets.mcp_exa.path})"
    export MCP_GITHUB="$(cat ${config.sops.secrets.mcp_github.path})"
  '';
}
