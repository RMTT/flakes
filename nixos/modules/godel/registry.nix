{
  server = [
    {
      name = "kube-runner";
      subnets = [
        "198.19.198.1/32"
        "10.42.0.0/24"
      ];
    }
    {
      name = "kube-edge";
      subnets = [
        "198.19.198.2/32"
        "10.42.1.0/24"
      ];
    }
    {
      name = "reck";
      subnets = [
        "198.19.198.101/32"
      ];
    }
    {
      name = "labrouter";
      subnets = [
        "198.19.198.254/32"
        "198.19.19.0/24"
      ];
    }
  ];
  client = [
    {
      name = "cn2-box";
      subnets = [
        "198.19.198.0/24"
        "10.42.0.0/16"
      ];
    }
  ];
}
