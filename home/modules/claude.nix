{ config, ... }:
{
  home.file.".claude/CLAUDE.md".source = ../config/claude/CLAUDE.md;

  sops.secrets.claude_base_url = {
    mode = "0444";
  };
  sops.secrets.claude_token = {
    mode = "0444";
  };

  programs.zsh.initContent = ''
    export ANTHROPIC_BASE_URL="$(cat ${config.sops.secrets.claude_base_url.path})"
    export ANTHROPIC_AUTH_TOKEN="$(cat ${config.sops.secrets.claude_token.path})"
    export CLAUDE_CODE_ENABLE_TELEMETRY=0
    export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
    export DISABLE_ERROR_REPORTING=1
    export DISABLE_TELEMETRY=1
  '';
}
