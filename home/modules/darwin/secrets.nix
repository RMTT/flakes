{ config, ... }:
{
  sops.secrets.claude_base_url = {
    mode = "0444";
  };
  sops.secrets.claude_token = {
    mode = "0444";
  };
}
