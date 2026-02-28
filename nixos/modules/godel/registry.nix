{
  server = [
    {
      name = "kube-runner";
      publicKey = "MFFzhL4jSJOlGVFh33Qwl24c63dBoyqTmSHS7lg2cAA=";
      allowedIPs = [
        "198.19.198.1/32"
        "10.42.0.0/24"
      ];
    }
    {
      name = "kube-edge";
      publicKey = "nmEsRr6GUqS7Iw7olSJMInH5Nn2GUo5O2rXj2cT6OG8=";
      allowedIPs = [
        "198.19.198.2/32"
        "10.42.1.0/24"
      ];
    }
    {
      name = "reck";
      publicKey = "wK3pClsL+hQECkK+PrKN+vp67F+62ac+bvpRirDSF1I=";
      allowedIPs = [
        "198.19.198.101/32"
      ];
    }
    {
      name = "homerouter";
      publicKey = "TU88NMaDOEIZ9s3JEkrcI2RfWNCVYwh9sd/xfRMeEBk=";
      allowedIPs = [
        "198.19.198.102/32"
        "198.19.19.0/24"
      ];
    }
  ];
  client = [
    {
      name = "cn2-box";
      publicKey = "QLOKC3sBuFG8BbNjZfM3pXa0yz5HRmq1khVppSniKB4=";
      allowedIPs = [
        "198.19.198.0/24"
        "10.42.0.0/16"
      ];
      endpoint = "cn2-box.rmtt.host:41820";
    }
  ];
}
