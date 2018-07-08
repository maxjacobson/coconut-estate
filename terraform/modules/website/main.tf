variable "allow_inbound_ssh_tag" {}
variable "allow_inbound_database_tag" {}
variable "bastion_host" {}
variable "host" {}
variable "ops_email" {}
variable "region" {}

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

resource "digitalocean_volume" "database_disk" {
  description = "A persistent volume to store the database's data on"
  name        = "database"
  region      = "${var.region}"
  size        = "20"
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
    "${digitalocean_volume.database_disk.id}",
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
    content     = "${data.template_file.secrets_fetcher.rendered}"
    destination = "/root/secrets-fetcher.bash"

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
    content     = "${data.template_file.api_service.rendered}"
    destination = "/etc/systemd/system/api.service"

    connection {
      type         = "ssh"
      bastion_host = "${var.bastion_host}"
      bastion_user = "coconut"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.generate_ssl_cert_script.rendered}"
    destination = "/root/generate-ssl-cert.bash"

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

resource "digitalocean_floating_ip" "website" {
  droplet_id = "${digitalocean_droplet.website.id}"
  region     = "${digitalocean_droplet.website.region}"
}

resource "digitalocean_domain" "website" {
  name       = "www.${var.host}"
  ip_address = "${digitalocean_floating_ip.website.ip_address}"

  # Just to make sure all three domains are created before running the provisioner...
  depends_on = [
    "digitalocean_domain.website_bare_domain",
    "digitalocean_domain.website_api_domain",
    "digitalocean_domain.database_domain",
  ]

  provisioner "remote-exec" {
    inline = ["/root/generate-ssl-cert.bash"]

    connection {
      host         = "${var.host}"
      type         = "ssh"
      bastion_host = "bastion.${var.host}"
      bastion_user = "coconut"
    }
  }
}

resource "digitalocean_domain" "website_bare_domain" {
  name       = "${var.host}"
  ip_address = "${digitalocean_floating_ip.website.ip_address}"
}

resource "digitalocean_domain" "website_api_domain" {
  name       = "api.${var.host}"
  ip_address = "${digitalocean_floating_ip.website.ip_address}"
}

resource "digitalocean_domain" "database_domain" {
  name       = "db.${var.host}"
  ip_address = "${digitalocean_floating_ip.website.ip_address}"
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

data "template_file" "generate_ssl_cert_script" {
  template = "${file("${path.module}/generate-ssl-cert.bash.tpl")}"

  vars {
    ops_email = "${var.ops_email}"

    api_domain      = "api.${var.host}"
    bare_domain     = "${var.host}"
    database_domain = "db.${var.host}"
    www_domain      = "www.${var.host}"
  }
}

data "template_file" "api_service" {
  template = "${file("${path.module}/api.service.tpl")}"

  vars {
    cors = "https://www.${var.host}"
  }
}

data "template_file" "postgresql_config" {
  template = "${file("${path.module}/postgresql.conf.tpl")}"

  # None currently - could stop using a template
  vars {}
}

data "template_file" "secrets_fetcher" {
  template = "${file("${path.module}/secrets-fetcher.bash.tpl")}"

  vars {
    secrets_host = "http://secrets.${var.host}"
  }
}
