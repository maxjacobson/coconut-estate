locals {
  api_host = "api.${var.host}"
}

variable "bastion_host" {}
variable "host" {}
variable "region" {}

variable "ssh_keys" {
  type = "list"
}

variable "tag" {}

resource "digitalocean_loadbalancer" "api" {
  name   = "api"
  region = "${var.region}"

  droplet_tag            = "${var.tag}"
  redirect_http_to_https = true

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 8080
    target_protocol = "http"
  }

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = 8080
    target_protocol = "http"

    certificate_id = "${digitalocean_certificate.api.id}"
  }

  # TODO: turn this back into an http check
  healthcheck {
    protocol = "tcp"
    port     = 22
  }
}

resource "digitalocean_domain" "api" {
  name       = "${local.api_host}"
  ip_address = "${digitalocean_loadbalancer.api.ip}"
}

resource "digitalocean_certificate" "api" {
  name = "api"
  type = "lets_encrypt"

  domains = ["${local.api_host}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "digitalocean_volume" "api" {
  description = "A persistent volume to store stuff on"
  name        = "api"
  region      = "${var.region}"
  size        = "1"
}

resource "digitalocean_droplet" "api" {
  image              = "ubuntu-18-04-x64"
  name               = "api"
  private_networking = true
  region             = "${var.region}"
  size               = "512mb"             # N.B. this is skimpy because I'm cheap and also no one uses the site at the moment
  ssh_keys           = ["${var.ssh_keys}"]
  tags               = ["${var.tag}"]

  volume_ids = [
    "${digitalocean_volume.api.id}",
  ]

  provisioner "file" {
    source      = "${path.module}/api-dummy.bash"
    destination = "/root/api-dummy.bash"

    connection {
      type         = "ssh"
      bastion_host = "${var.bastion_host}"
      bastion_user = "coconut"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.api_service.rendered}"
    destination = "/etc/systemd/system/api.service"

    connection {
      type         = "ssh"
      bastion_host = "${var.bastion_host}"
      bastion_user = "coconut"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.secrets_fetcher.rendered}"
    destination = "/root/secrets-fetcher.bash"

    connection {
      type         = "ssh"
      bastion_host = "${var.bastion_host}"
      bastion_user = "coconut"
    }
  }

  provisioner "remote-exec" {
    script = "${path.module}/prepare-droplet.bash"
  }
}

data "template_file" "api_service" {
  template = "${file("${path.module}/api.service.tpl")}"

  vars {
    cors = "https://www.${var.host}"
  }
}

data "template_file" "secrets_fetcher" {
  template = "${file("${path.module}/secrets-fetcher.bash.tpl")}"

  vars {
    secrets_host = "http://secrets.${var.host}"
  }
}

# TODO: set up firewall

