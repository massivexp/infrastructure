variable "salt_master_droplet_id" {}
variable "salt_master_private_ip_address" {}
variable "salt_master_public_ip_address" {}
variable "autogenerated_ssh_private_key" {}

variable "ssh_keys" {}
variable "couchdb_user" {}
variable "couchdb_pass" {}
variable "couchdb_droplet_ids" {}
variable "image" {}
variable "pm2_nodes" {}
variable "proxy_provisioned" {}
variable "proxy_size" {}
variable "api_size" {}
variable "tld" {}
variable "name" {}
variable "app_npm_package" {}
variable "github_token" {}

variable "heartbeat_private_ip_address" {
  default = ""
}

variable "root_domain" {
  default = false
}

variable "stripe_api_key" {
  default = ""
}

variable "http_interface" {
  default = false
}

module "PM2Node" {
  source = "../salt-minion"
  node_count = var.pm2_nodes
  provision = true

  name = "nodejs-${var.name}"
  domain_id = var.tld
  keys = var.ssh_keys
  image = var.image
  size = var.api_size
  github_token = var.github_token

  salt_minion_roles = ["pm2", "minion"]
  salt_master_droplet_id = var.salt_master_droplet_id
  salt_master_private_ip_address = var.salt_master_private_ip_address
  salt_master_public_ip_address = var.salt_master_public_ip_address
  autogenerated_ssh_private_key = var.autogenerated_ssh_private_key
  couch_user = var.couchdb_user
  couch_pass = var.couchdb_pass
  stripe_api_key = var.stripe_api_key
}

module "HAProxy" {
  source = "../salt-minion"
  node_count = var.proxy_provisioned && var.http_interface ? 1 : 0
  provision = var.proxy_provisioned && var.http_interface ? true : false
  name = "haproxy-nodejs-${var.name}"
  size = var.proxy_size
  domain_id = var.tld
  custom_fqdn = var.name
  keys = var.ssh_keys
  image = var.image

  salt_minion_roles = var.root_domain ? ["haproxy", "pm2", "minion", "root"] : ["haproxy", "pm2", "minion"]
  salt_master_droplet_id = var.salt_master_droplet_id
  salt_master_private_ip_address = var.salt_master_private_ip_address
  salt_master_public_ip_address = var.salt_master_public_ip_address
  autogenerated_ssh_private_key = var.autogenerated_ssh_private_key
}

# Round robin dns for haproxy instances
resource "digitalocean_record" "nodejsapi_frontend" {
  count = var.proxy_provisioned && var.http_interface ? 1 : 0
  domain = var.tld
  type = "A"
  name = var.name
  value = module.HAProxy.salt_minion_public_ip_addresses[0]
}

resource "digitalocean_record" "root_domain" {
  count = var.root_domain && var.http_interface ? 1 : 0
  domain = var.tld
  type = "A"
  name = "@"
  value = module.HAProxy.salt_minion_public_ip_addresses[0]
}

resource "digitalocean_firewall" "nodejsapihaproxy_to_nodejsapi" {
  name="JS-${var.name}-HAProxy-NodeJSApi"
  droplet_ids = module.PM2Node.droplet_ids

  inbound_rule {
    protocol = "tcp"
    port_range = "3000"
    source_addresses = module.HAProxy.salt_minion_private_ip_addresses
  }

}

resource "digitalocean_firewall" "heartbeat_to_nodejsapi" {
  name="JS-${var.name}-Heartbeat-NodeJSApi"
  count = var.heartbeat_private_ip_address != "" ? 1 : 0
  droplet_ids = module.PM2Node.droplet_ids

  inbound_rule {
    protocol = "tcp"
    port_range = "3000"
    source_addresses = [var.heartbeat_private_ip_address]
  }

}



resource "digitalocean_firewall" "world_to_nodejsapi_haproxy" {
  name="World-To-JS-${var.name}-HAProxy"
  droplet_ids = module.HAProxy.droplet_ids

  inbound_rule {
    protocol = "tcp"
    port_range = "80"
    source_addresses = ["0.0.0.0/0"]
  }

  inbound_rule {
    protocol = "tcp"
    port_range = "443"
    source_addresses = ["0.0.0.0/0"]
  }

}

resource "digitalocean_firewall" "nodejsapi_to_couchdb" {
  name="JS-${var.name}-To-CouchDB"
  droplet_ids = var.couchdb_droplet_ids

  inbound_rule {
    protocol = "tcp"
    port_range = "5984"
    source_addresses = module.PM2Node.salt_minion_private_ip_addresses
  }

}

output "pm2_node_private_ip_addresses" {
  value = module.PM2Node.salt_minion_private_ip_addresses
}

output "haproxy_private_ip_addresses" {
  value = module.HAProxy.salt_minion_private_ip_addresses
}
