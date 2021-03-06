terraform {
  required_providers {
    linode = {
      source = "linode/linode"
    }
  }
}

provider "linode" {
    token = var.token
    api_version = "v4beta"
}

resource "linode_instance" "debiL" {
    label = "debian-us-southeast"
    image = "linode/debian11"
    region = var.region
    type = "g6-nanode-1"
    authorized_keys = [var.ssh_key]
    root_pass = var.root_pass
}

resource "linode_domain" "dominio_linode" {
    domain = "eclaros.xyz"
    soa_email = "eclaros@fi.uba.ar"
    type = "master"
}

resource "linode_domain_record" "domain_linode_record" {
    domain_id = linode_domain.dominio_linode.id
    name = "www"
    record_type = "A"
    target = linode_instance.debiL.ip_address
    ttl_sec = 300
}

# Add a record to the domain
resource "linode_domain_record" "mail" {
  domain_id = linode_domain.dominio_linode.id
  record_type   = "A"
  name   = "mail"
  ttl_sec    = "30"
  target = linode_instance.debiL.ip_address
}

# Add mx record to the domain (so it can receive emails)
resource "linode_domain_record" "mx" {
  domain_id = linode_domain.dominio_linode.id
  record_type   = "MX"
  name   = ""
  priority    = "10"
  ttl_sec    = "14400"
  target = "mail.eclaros.xyz"
}

# SPF
resource "linode_domain_record" "spf" {
  domain_id = linode_domain.dominio_linode.id
  record_type   = "TXT"
  name        = ""
  target      = "v=spf1 include:spf.eclaros.xyz -all"
  ttl_sec    = "14400"
}

# DMARC
resource "linode_domain_record" "dmarc" {
  domain_id = linode_domain.dominio_linode.id
  record_type   = "TXT"
   name        = "_dmarc"
  target      = "v=DMARC1;v=DMARC1; p=none; rua=mailto:dmarc-reports@eclaros.xyz"
}
variable "token" {}
variable "root_pass" {}
variable "ssh_key" {}
variable "region" {
  default = "us-southeast"
}