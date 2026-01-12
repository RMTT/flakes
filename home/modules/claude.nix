{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.file.".claude/CLAUDE.md".source = ../config/claude/CLAUDE.md;
  sops.secrets.claude_base_url = {
    mode = "0444";
  };
  sops.secrets.claude_token = {
    mode = "0444";
  };
  sops.secrets.mcps = {
    mode = "0400";
    sopsFile = ../secrets/mcps.json;
    format = "binary";
  };

  programs.zsh.initContent = ''
    export ANTHROPIC_BASE_URL="$(cat ${config.sops.secrets.claude_base_url.path})"
    export ANTHROPIC_AUTH_TOKEN="$(cat ${config.sops.secrets.claude_token.path})"
    export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.5-air"
    export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.7"
    export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-4.7"
  '';

  home.activation = {
    claude = lib.hm.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
      merge_mcps() {
        old_file=~/.claude.json
        if [ ! -f "$old_file" ]; then
          echo '{}' > "$old_file"
        else
          cp "$old_file" "$old_file".bak
          ${lib.getExe pkgs.jq} -s '.[0] + .[1]' "$old_file" ${config.sops.secrets.mcps.path} > "$old_file".new
          cp "$old_file".new "$old_file"
          rm "$old_file".new
        fi
      }

      run merge_mcps
    '';
  };
}
