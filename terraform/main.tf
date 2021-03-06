terraform {
  backend "remote" {
    required_version = "0.12.25"
    hostname = "app.terraform.io"
    organization = "massivexp"

    workspaces {
      name = "infrastructure"
    }
  }
}

variable "stripe_api_key" {}
variable "digitalocean_api_token" {}
variable "terraform_cloud_api_token" {}
variable "geoip_license_key" {}
variable "geoip_account_id" {}
variable "github_token" {}

variable "mwk_key_fingerprint" {
  type = string
}

provider "digitalocean" {
  token = var.digitalocean_api_token
}

provider "tfe" {
  hostname = "app.terraform.io"
  token = var.terraform_cloud_api_token
}

resource "tls_private_key" "autogenerated" {
  algorithm = "RSA"
}

resource "digitalocean_ssh_key" "autogenerated" {
  name = "Salt Master"
  public_key = tls_private_key.autogenerated.public_key_openssh
}

variable "base_image" {
  default = "freebsd-12-x64-zfs"
}

variable "cluster_makeup" {
  default = {
    tld = "massivexp.com"

    salt_master = {
      size = "s-1vcpu-1gb"
    }

    logging = {
      heartbeat_provisioned = true
      heartbeat_size = "s-1vcpu-1gb"
      elastic_size = "s-2vcpu-4gb"
      elastic_disk = 100
      kibana_proxy_size = "s-1vcpu-1gb"
      kibana_size = "s-2vcpu-2gb"
      kibana_proxy_provisioned = true
      kibana_domain = "dashboard"
      logstash_size = "s-1vcpu-1gb"
      logstash_node_count = 1
      elastic_disk_size = 30
      elastic_node_count = 1
      apm_size = "s-1vcpu-1gb"
      apm_domain = "apm"
    }

    couchdb = {
      couch_size = "s-2vcpu-2gb"
      proxy_size = "s-1vcpu-1gb"
      proxy_provisioned = true
      haproxy_domain = "couchdb"
      node_count = 1
      disk_size = 30
    }

    api = {
      api_size = "s-1vcpu-1gb"
      proxy_size = "s-1vcpu-1gb"
      api_node_count = 1
      proxy_provisioned = true
    }

    app = {
      node_count = 1
    }

    angular = {
      size = "s-1vcpu-1gb"
    }

  }

}

resource "digitalocean_firewall" "ping_all_public" {
  name="all-public-pinged"
  droplet_ids = concat(
    [module.Salt_Master.droplet_id]
  )

  inbound_rule {
    protocol = "icmp"
    source_addresses = ["0.0.0.0/1"]
  }

}

module "Salt_Master" {
  source = "./modules/salt-master"
  name = "saltm"
  tld = var.cluster_makeup.tld

  keys = [
    var.mwk_key_fingerprint,
    digitalocean_ssh_key.autogenerated.fingerprint
  ]

  disk_size = 1
  image = var.base_image
  size = var.cluster_makeup.salt_master.size
  domain_id = var.cluster_makeup.tld
  autogenerated_ssh_private_key = tls_private_key.autogenerated.private_key_pem
}

module "ELK" {
  source = "./modules/elk"
  image = var.base_image
  tld = var.cluster_makeup.tld

  kibana_domain = var.cluster_makeup.logging.kibana_domain
  kibana_size = var.cluster_makeup.logging.kibana_size
  kibana_proxy_size = var.cluster_makeup.logging.kibana_proxy_size
  kibana_proxy_provisioned = var.cluster_makeup.logging.kibana_proxy_provisioned
  logstash_size = var.cluster_makeup.logging.logstash_size
  logstash_workers = var.cluster_makeup.logging.logstash_node_count
  elasticsearch_workers = var.cluster_makeup.logging.elastic_node_count
  elasticsearch_size = var.cluster_makeup.logging.elastic_size
  elasticsearch_disk = var.cluster_makeup.logging.elastic_disk
  heartbeat_size = var.cluster_makeup.logging.heartbeat_size
  heartbeat_provisioned = var.cluster_makeup.logging.heartbeat_provisioned
  apm_size = var.cluster_makeup.logging.apm_size
  apm_domain = var.cluster_makeup.logging.apm_domain
  #heartbeat_access_droplet_ids = module.CouchDB.droplet_ids

  geoip_license_key = var.geoip_license_key
  geoip_account_id = var.geoip_account_id

  all_droplet_ips = concat(
    [module.Salt_Master.private_ip_address],
    module.CouchDB.couchdb_node_private_ip_addresses,
    module.CouchDB.haproxy_private_ip_addresses,
    module.Pipeline-Reactions.pm2_node_private_ip_addresses,
    module.Pipeline-Reactions.haproxy_private_ip_addresses,
    module.API.pm2_node_private_ip_addresses,
    module.API.haproxy_private_ip_addresses
  )

  salt_master_droplet_id = module.Salt_Master.droplet_id
  salt_master_private_ip_address = module.Salt_Master.private_ip_address
  salt_master_public_ip_address = module.Salt_Master.public_ip_address
  autogenerated_ssh_private_key = tls_private_key.autogenerated.private_key_pem

  ssh_keys = [
    digitalocean_ssh_key.autogenerated.fingerprint,
    module.Salt_Master.ssh_fingerprint
  ]

}

module "CouchDB" {
  source = "./modules/couchdb"
  image = var.base_image
  tld = var.cluster_makeup.tld

  disk_size = var.cluster_makeup.couchdb.disk_size

  haproxy_domain = var.cluster_makeup.couchdb.haproxy_domain
  couchdb_size = var.cluster_makeup.couchdb.couch_size
  proxy_size = var.cluster_makeup.couchdb.proxy_size
  couchdb_replicas = var.cluster_makeup.couchdb.node_count
  couchdb_proxy_online = var.cluster_makeup.couchdb.proxy_provisioned

  salt_master_droplet_id = module.Salt_Master.droplet_id
  salt_master_private_ip_address = module.Salt_Master.private_ip_address
  salt_master_public_ip_address = module.Salt_Master.public_ip_address
  autogenerated_ssh_private_key = tls_private_key.autogenerated.private_key_pem

  heartbeat_private_ip_addresses = module.ELK.heartbeat_private_ip_addresses

  #jwt = module.API.jwt

  ssh_keys = [
    digitalocean_ssh_key.autogenerated.fingerprint,
    module.Salt_Master.ssh_fingerprint
  ]

}

module "API" {
  source = "./modules/nodejs"
  image = var.base_image
  tld = var.cluster_makeup.tld

  name = "api"
  app_npm_package = "@massivexp/api"
  github_token = var.github_token
  http_interface = true
  #jwt = true

  api_size = var.cluster_makeup.api.api_size
  proxy_size = var.cluster_makeup.api.proxy_size
  proxy_provisioned = var.cluster_makeup.api.proxy_provisioned
  pm2_nodes = var.cluster_makeup.api.api_node_count
  couchdb_user = module.CouchDB.user
  couchdb_pass = module.CouchDB.pass
  stripe_api_key = var.stripe_api_key
  couchdb_droplet_ids = module.CouchDB.droplet_ids

  salt_master_droplet_id = module.Salt_Master.droplet_id
  salt_master_private_ip_address = module.Salt_Master.private_ip_address
  salt_master_public_ip_address = module.Salt_Master.public_ip_address
  autogenerated_ssh_private_key = tls_private_key.autogenerated.private_key_pem

  heartbeat_private_ip_addresses = module.ELK.heartbeat_private_ip_addresses

  ssh_keys = [
    digitalocean_ssh_key.autogenerated.fingerprint,
    module.Salt_Master.ssh_fingerprint
  ]

}

module "Pipeline-Reactions" {
  source = "./modules/nodejs"
  image = var.base_image
  tld = var.cluster_makeup.tld

  name = "pipeline"
  app_npm_package = "@massivexp/pipeline"
  github_token = var.github_token
  http_interface = false

  api_size = var.cluster_makeup.api.api_size
  proxy_size = var.cluster_makeup.api.proxy_size
  proxy_provisioned = var.cluster_makeup.api.proxy_provisioned
  pm2_nodes = var.cluster_makeup.api.api_node_count
  couchdb_user = module.CouchDB.user
  couchdb_pass = module.CouchDB.pass
  couchdb_droplet_ids = module.CouchDB.droplet_ids

  salt_master_droplet_id = module.Salt_Master.droplet_id
  salt_master_private_ip_address = module.Salt_Master.private_ip_address
  salt_master_public_ip_address = module.Salt_Master.public_ip_address
  autogenerated_ssh_private_key = tls_private_key.autogenerated.private_key_pem

  ssh_keys = [
    digitalocean_ssh_key.autogenerated.fingerprint,
    module.Salt_Master.ssh_fingerprint
  ]

}

module "App" {
  source = "./modules/nodejs"
  image = var.base_image
  tld = var.cluster_makeup.tld

  name = "www"
  app_npm_package = "@massivexp/massivexp"
  github_token = var.github_token
  http_interface = true
  root_domain = true

  api_size = var.cluster_makeup.api.api_size
  proxy_size = var.cluster_makeup.api.proxy_size
  proxy_provisioned = var.cluster_makeup.api.proxy_provisioned
  pm2_nodes = var.cluster_makeup.app.node_count
  couchdb_user = module.CouchDB.user
  couchdb_pass = module.CouchDB.pass
  couchdb_droplet_ids = module.CouchDB.droplet_ids

  salt_master_droplet_id = module.Salt_Master.droplet_id
  salt_master_private_ip_address = module.Salt_Master.private_ip_address
  salt_master_public_ip_address = module.Salt_Master.public_ip_address
  autogenerated_ssh_private_key = tls_private_key.autogenerated.private_key_pem

  heartbeat_private_ip_addresses = module.ELK.heartbeat_private_ip_addresses

  ssh_keys = [
    digitalocean_ssh_key.autogenerated.fingerprint,
    module.Salt_Master.ssh_fingerprint
  ]

}
