{ self, ... }:
{
  nodes = {
    cn2-box.host = "cn2-box.rmtt.host";
    oracle = {
      host = "oracle.rmtt.host";
      remoteBuild = true;
    };
  };
}
