variable "allow_inbound_tag" {}
variable "bastion_host" {}
variable "host" {}
variable "region" {}

variable "ssh_keys" {
  type = "list"
}

variable "tags" {
  type = "list"
}

locals {
  domain_name = "www.${var.host}"
}

resource "digitalocean_volume" "disk" {
  description = "A persistent volume to store stuff on"
  name        = "website"
  region      = "${var.region}"
  size        = "1"
}

resource "digitalocean_droplet" "website" {
  image              = "ubuntu-16-04-x64"
  name               = "website"
  private_networking = true
  region             = "${var.region}"
  size               = "s-3vcpu-1gb"
  ssh_keys           = ["${var.ssh_keys}"]
  tags               = ["${var.tags}"]
  volume_ids         = ["${digitalocean_volume.disk.id}"]

  provisioner "file" {
    source      = "${path.module}/website-dummy.bash"
    destination = "/root/website-dummy.bash"

    connection {
      type         = "ssh"
      bastion_host = "${var.bastion_host}"
      bastion_user = "coconut"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.nginx.rendered}"
    destination = "/root/nginx.conf"

    connection {
      type         = "ssh"
      bastion_host = "${var.bastion_host}"
      bastion_user = "coconut"
    }
  }

  provisioner "file" {
    source      = "${path.module}/website.service"
    destination = "/etc/systemd/system/website.service"

    connection {
      type         = "ssh"
      bastion_host = "${var.bastion_host}"
      bastion_user = "coconut"
    }
  }

  provisioner "remote-exec" {
    script = "${path.module}/prepare-droplet.bash"

    connection {
      type         = "ssh"
      bastion_host = "bastion.${var.host}"
      bastion_user = "coconut"
    }
  }

  # because the prepare script won't be able to run unless the firewall permits
  # outbound access, and we don't want this thing to come online before the
  # firewall is protecting it
  depends_on = ["digitalocean_firewall.website"]
}

resource "digitalocean_floating_ip" "website" {
  droplet_id = "${digitalocean_droplet.website.id}"
  region     = "${digitalocean_droplet.website.region}"
}

resource "digitalocean_domain" "website" {
  name       = "${local.domain_name}"
  ip_address = "${digitalocean_floating_ip.website.ip_address}"
}

resource "digitalocean_firewall" "website" {
  name = "website"

  # the droplets to apply the rule to
  tags = ["${var.tags}"]

  inbound_rule = [
    {
      protocol    = "tcp"
      port_range  = "22"
      source_tags = ["${var.allow_inbound_tag}"]
    },
    {
      protocol         = "tcp"
      port_range       = "80"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "tcp"
      port_range       = "443"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]

  outbound_rule = [
    {
      protocol = "icmp"

      destination_addresses = ["0.0.0.0/0", "::/0"]
      port_range            = "1-65535"
    },
    {
      protocol = "tcp"

      destination_addresses = ["0.0.0.0/0", "::/0"]
      port_range            = "1-65535"
    },
    {
      protocol = "udp"

      destination_addresses = ["0.0.0.0/0", "::/0"]
      port_range            = "1-65535"
    },
  ]
}

data "template_file" "nginx" {
  template = "${file("${path.module}/nginx.conf.tpl")}"

  vars {
    server_name = "${local.domain_name}"
  }
}
