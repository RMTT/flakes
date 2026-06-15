{ self, ... }:
{
  nodes = {
    mtspc.host = "localhost";
    cn2-box.host = "cn2-box.rmtt.host";
    oracle = {
      host = "oracle.rmtt.host";
      remoteBuild = true;
    };
    homeserver.host = "homeserver.infra.rmtt.host";
  };
}
