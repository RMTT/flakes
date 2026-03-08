{
  tunnel,
  port,
}:
{
  server = [
    {
      # name = "kube-runner";
      publicKey = "EuVnDGoBHuj68HQK6j9T5wgPr0r8SBFOShm4/imxlgA=";
      allowedIPs = [
        "198.19.198.1/32"
        "10.42.0.0/24"
      ];
    }
    {
      # name = "kube-edge";
      publicKey = "nmEsRr6GUqS7Iw7olSJMInH5Nn2GUo5O2rXj2cT6OG8=";
      allowedIPs = [
        "198.19.198.2/32"
        "10.42.1.0/24"
      ];
    }
    {
      # name = "reck";
      publicKey = "wK3pClsL+hQECkK+PrKN+vp67F+62ac+bvpRirDSF1I=";
      allowedIPs = [
        "198.19.198.101/32"
      ];
    }
    # {
    #   # name = "homerouter";
    #   publicKey = "TU88NMaDOEIZ9s3JEkrcI2RfWNCVYwh9sd/xfRMeEBk=";
    #   allowedIPs = [
    #     "198.19.198.102/32"
    #     "198.19.19.0/24"
    #   ];
    # }
  ];
  client = [
    {
      # name = "cn2-box";
      publicKey = "eJZkYrAVDYh3km7oEjv9E5jhFbWsUIrQWnQzqy/2sis=";
      allowedIPs = [
        "198.19.198.0/24"
        "10.42.0.0/16"
      ];
      endpoint =
        if tunnel then "127.0.0.1:${toString (port)}" else "cn2-box.rmtt.host:${toString (port)}";
      persistentKeepalive = 25;
    }
  ];
}
