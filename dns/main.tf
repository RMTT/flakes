terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.5"
    }
  }
}

data "sops_file" "secrets" {
  source_file = "keys.yaml"
}

provider "cloudflare" {
  api_token = data.sops_file.secrets.data["CLOUDFLARE_API_TOKEN"]
}

variable "cf_record_id_file" {
  type    = string
  default = "./cf_ids.yaml"

  validation {
    condition     = fileexists(var.cf_record_id_file)
    error_message = "⚠️ cannot find ./cf_ids.yaml, please create it via 'sops exec-env ./keys.yaml cf-record-ids'"
  }
}

locals {
  zone_lookup = {
    "rmtt.tech" = data.sops_file.secrets.data["cf_zone_rmtt_tech"]
    "rmtt.fun"  = data.sops_file.secrets.data["cf_zone_rmtt_fun"]
    "rmtt.host" = data.sops_file.secrets.data["cf_zone_rmtt_host"]
  }

  cf_ids = yamldecode(file(var.cf_record_id_file))
  import_dns = {
    for domain, config in local.filtered_dns :
    domain => config
    if lookup(local.cf_ids, domain, null) != null
  }

  raw_list = yamldecode(file("${path.module}/hosts.yaml"))
  filtered_dns = {
    for x in local.raw_list : "${x.name}.${x.zone}" => x
    if x.push == true
  }
}

import {
  for_each = local.import_dns

  to = cloudflare_dns_record.dynamic[each.key]
  id = "${local.zone_lookup[each.value.zone]}/${local.cf_ids[each.key]}"
}

resource "cloudflare_dns_record" "dynamic" {
  for_each = { for x in local.filtered_dns : "${x.name}.${x.zone}" => x }

  zone_id = local.zone_lookup[each.value.zone]
  name    = each.value.name
  content = each.value.value
  type    = "A"
  ttl     = 1
  comment = "records created by terraform"
}
