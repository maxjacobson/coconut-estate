# TODO: remove all references to database
variable "allow_inbound_ssh_tag" {}

variable "allow_inbound_database_tag" {}
variable "bastion_host" {}
variable "host" {}
variable "ops_email" {}
variable "region" {}
variable "website_tag" {}

variable "ssh_keys" {
  type = "list"
}

variable "tags" {
  type = "list"
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

  volume_ids = [
    "${digitalocean_volume.disk.id}",
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
    content     = "${data.template_file.nginx.rendered}"
    destination = "/root/nginx.conf"

    connection {
      type         = "ssh"
      bastion_host = "${var.bastion_host}"
      bastion_user = "coconut"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.postgresql_config.rendered}"
    destination = "/root/postgresql.conf"

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

resource "digitalocean_domain" "website" {
  name = "www.${var.host}"
}

resource "digitalocean_record" "website" {
  domain = "${digitalocean_domain.website.name}"
  type   = "A"
  name   = "website"
  value  = "${digitalocean_loadbalancer.website.ip}"
}

resource "digitalocean_domain" "website_bare_domain" {
  name = "${var.host}"
}

resource "digitalocean_record" "website_bare_domain" {
  domain = "${digitalocean_domain.website_bare_domain.name}"
  type   = "A"
  name   = "website-bare-domain"
  value  = "${digitalocean_loadbalancer.website.ip}"
}

resource "digitalocean_loadbalancer" "website" {
  name   = "website"
  region = "${var.region}"

  droplet_tag            = "${var.website_tag}"
  redirect_http_to_https = true

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"

    # certificate_id = "${digitalocean_certificate.website.id}"
  }

  # TODO: turn this back into an http check
  healthcheck {
    protocol = "tcp"
    port     = 22
  }
}

resource "digitalocean_firewall" "website" {
  name = "website"

  # the droplets to apply the rule to
  tags = ["${sort(var.tags)}"]

  inbound_rule = [
    {
      protocol    = "tcp"
      port_range  = "22"
      source_tags = ["${var.allow_inbound_ssh_tag}"]
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
    {
      protocol    = "tcp"
      port_range  = "5432"
      source_tags = ["${var.allow_inbound_database_tag}"]
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
    server_name = "${var.host}"
  }
}

data "template_file" "postgresql_config" {
  template = "${file("${path.module}/postgresql.conf.tpl")}"

  # None currently - could stop using a template
  vars {}
}
