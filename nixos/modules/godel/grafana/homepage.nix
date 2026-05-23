pkgs:
let
  # get icon url from https://dashboardicons.com/
  internalServices = [
    {
      name = "Homeserver";
      url = "https://homeserver.rmtt.tech";
      icon = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/proxmox-light.svg";
      desc = "Proxmox VE for VM and CTs";
    }
    {
      name = "Proxmox Backup";
      url = "https://pbs.rmtt.tech";
      icon = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/proxmox-backup-server.svg";
      desc = "Proxmox Backup Server";
    }
    {
      name = "TrueNAS";
      url = "https://nas.rmtt.tech";
      icon = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/truenas.svg";
      desc = "Primary Storage";
    }
    {
      name = "OpenWrt";
      url = "https://homerouter.java-crocodile.ts.net";
      icon = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/openwrt.svg";
      desc = "Gateway Router of Home";
    }
    {
      name = "Prometheus";
      url = "https://prometheus.rmtt.tech";
      icon = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/prometheus.svg";
      desc = "Prometheus instance of Homelab";
    }
    {
      name = "Adguardhome";
      url = "http://homerouter.java-crocodile.ts.net:3000";
      icon = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/adguard-home.svg";
      desc = "Local DNS of Home";
    }
    {
      name = "Traefik on oracle";
      url = "https://oracle.proxy.rmtt.tech";
      icon = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/traefik-proxy.svg";
      desc = "Traefik for proxing service in homelab hosts";
    }
    {
      name = "Traefik on kube-runner";
      url = "https://kube-runner.proxy.rmtt.tech";
      icon = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/traefik-proxy.svg";
      desc = "Traefik for proxing service in k3s cluster";
    }
  ];

  externalServices = [
    {
      name = "Uptime";
      url = "https://status.rmtt.tech";
      icon = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/gatus.svg";
      desc = "Uptime monitor of homelab";
    }
    {
      name = "Grafana";
      url = "https://grafana.rmtt.tech";
      icon = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/grafana.svg";
      desc = "Grafana dashboard of homelab";
    }
    {
      name = "Nextcloud";
      url = "https://cloud.rmtt.tech";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/nextcloud.svg";
      desc = "Cloud Storage";
    }
    {
      name = "Authelia";
      url = "https://auth.rmtt.tech";
      icon = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/authelia.svg";
      desc = "Authentic provider";
    }
    {
      name = "Karakeep";
      url = "https://karakeep.rmtt.tech";
      icon = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/karakeep.svg";
      desc = "Bookmarks and RSS subscriptions";
    }
    {
      name = "n8n";
      url = "https://n8n.rmtt.tech";
      icon = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/n8n.svg";
      desc = "Workflow";
    }
    {
      name = "Miniflux";
      url = "https://miniflux.rmtt.tech";
      icon = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/miniflux.svg";
      desc = "RSS Reader";
    }
  ];


  cssStyle = ''
    <style>
      .nexus-grid { display: flex; flex-wrap: wrap; gap: 15px; width: 100%; }
      .nexus-card { background: #1a1b1e; border: 1px solid #333; padding: 15px 20px; border-radius: 8px; text-decoration: none; display: flex; align-items: center; gap: 15px; min-width: 220px; transition: 0.2s; }
      .nexus-card:hover { background: #25272b; border-color: #555; transform: translateY(-2px); }
      .nexus-icon { width: 36px; height: 36px; display: flex; justify-content: center; align-items: center; flex-shrink: 0; }
      .nexus-icon img { max-width: 100%; max-height: 100%; object-fit: contain; border: none; }
      .nexus-text { display: flex; flex-direction: column; }
      .nexus-text strong { color: #fff; font-size: 16px; }
      .nexus-text small { color: #888; font-size: 12px; }
    </style>
  '';

  genCardsHtml =
    services:
    builtins.concatStringsSep "" (
      map (s: ''
        <a href="${s.url}" target="_blank" class="nexus-card">
          <div class="nexus-icon">
            <img src="${s.icon}" alt="${s.name}" />
          </div>
          <div class="nexus-text">
            <strong>${s.name}</strong>
            <small>${s.desc}</small>
          </div>
        </a>
      '') services
    );

  internalHtml = "${cssStyle}<div class=\"nexus-grid\">${genCardsHtml internalServices}</div>";
  externalHtml = "${cssStyle}<div class=\"nexus-grid\">${genCardsHtml externalServices}</div>";

  dashboardSchema = {
    id = null;
    uid = "homelab-nexus-portal";
    title = "Homepage";
    tags = [ "homepage" ];
    style = "dark";
    timezone = "browser";
    editable = false;
    panels = [
      {
        id = 1;
        type = "text";
        title = "🏠 Internal Services (LAN Only)";
        transparent = true;
        gridPos = {
          h = 10;
          w = 24;
          x = 0;
          y = 0;
        };
        options = {
          mode = "html";
          content = internalHtml;
        };
      }
      {
        id = 2;
        type = "text";
        title = "🌍 External Nodes (WAN and LAN)";
        transparent = true;
        gridPos = {
          h = 10;
          w = 24;
          x = 0;
          y = 6;
        };
        options = {
          mode = "html";
          content = externalHtml;
        };
      }
    ];
    schemaVersion = 39;
    version = 1;
  };
in
pkgs.writeTextDir "homepage.json" (builtins.toJSON dashboardSchema)
