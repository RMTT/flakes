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
  sops.templates.opencode-setting = {
    path = "${config.home.homeDirectory}/.config/opencode/opencode.json";
    content = ''
      {
        "$schema": "https://opencode.ai/config.json",
        "plugin": [
          "@mohak34/opencode-notifier@latest",
          "opencode-gemini-auth@latest"
        ],
        "keybinds": {
          "command_list": "<leader>p",
          "history_previous": "ctrl+p",
          "history_next": "ctrl+n"
        },
        "mcp": {
          "context7": {
            "type": "remote",
            "url": "https://mcp.context7.com/mcp",
            "headers": { "CONTEXT7_API_KEY": "${config.sops.placeholder.mcp_context7}"
            }
          },
          "github": {
            "type": "remote",
            "url": "https://api.githubcopilot.com/mcp",
            "headers": {
              "Authorization": "Bearer ${config.sops.placeholder.mcp_github}"
            }
          },
          "exa": {
            "type": "remote",
            "url": "https://mcp.exa.ai/mcp?exaApiKey=${config.sops.placeholder.mcp_exa}",
            "headers": {}
          }
        }
      }
    '';
  };

  xdg.configFile."opencode/AGENTS.md".source = ../config/agents/AGENTS.md;
  home.file.".gemini/GEMINI.md".source = ../config/agents/AGENTS.md;

  programs.zsh.initContent = ''
    export MCP_CONTEXT7="$(cat ${config.sops.secrets.mcp_context7.path})"
    export MCP_EXA="$(cat ${config.sops.secrets.mcp_exa.path})"
    export MCP_GITHUB="$(cat ${config.sops.secrets.mcp_github.path})"
  '';
}
