{ self, ... }:
{
  nodes = {
    mtspc.host = "localhost";
    cn2-box.host = "cn2-box.rmtt.host";
    oracle = {
      host = "oracle.rmtt.host";
      remoteBuild = true;
    };
    kube-runner.host = "kube-runner.infra.rmtt.host";
    labrouter.host = "labrouter.infra.rmtt.host";
    agent.host = "agent.infra.rmtt.host";
  };
}
