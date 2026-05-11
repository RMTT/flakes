{ ... }:
{
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    allowedHosts = "198.19.19.1:8082,homepage.rmtt.tech";
    settings = {
      title = "MT's Homelab";
      description = "Recording my services";
    };
    widgets = [
      {
        greeting = {
          text_size = "xl";
          text = "Welcome";
        };
        datetime = {
          text_size = "xl";
          format = {
            timeStyle = "short";
          };
        };
      }
    ];
    services = [
      {
        "My First Group" = [
          {
            "My First Service" = {
              description = "Homepage is awesome";
              href = "http://localhost/";
            };
          }
        ];
      }
      {
        "My Second Group" = [
          {
            "My Second Service" = {
              description = "Homepage is the best";
              href = "http://localhost/";
            };
          }
        ];
      }
    ];
    bookmarks = [
      {
        Developer = [
          {
            Github = [
              {
                abbr = "GH";
                href = "https://github.com/";
              }
            ];
          }
        ];
      }
      {
        Entertainment = [
          {
            YouTube = [
              {
                abbr = "YT";
                href = "https://youtube.com/";
              }
            ];
          }
        ];
      }
    ];
  };
}
