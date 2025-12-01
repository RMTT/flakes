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
  '';

}
