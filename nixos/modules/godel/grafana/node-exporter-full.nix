pkgs:
let
  version = "45";
  nodeExporterFullJsonFile = pkgs.fetchurl {
    name = "node-exporter-full.json";
    url = "https://grafana.com/api/dashboards/1860/revisions/${version}/download";
    sha256 = "sha256-GExrdAnzBtp1Ul13cvcZRbEM6iOtFrXXjEaY6g6lGYY=";
  };
in
nodeExporterFullJsonFile
