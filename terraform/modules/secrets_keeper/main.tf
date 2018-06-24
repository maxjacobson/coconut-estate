variable "bastion_host" {}
variable "host" {}
variable "region" {}

variable "ssh_keys" {
  type = "list"
}

variable "tags" {
  type = "list"
}

variable "allow_inbound_tag" {}

resource "digitalocean_volume" "disk" {
  description = "A persistent volume to store secrets on"
  name        = "secrets-keeper"
  region      = "${var.region}"
  size        = "1"
}

# Server to run the secrets keeper web service on
resource "digitalocean_droplet" "web" {
  image              = "ubuntu-16-04-x64"
  name               = "secrets-keeper"
  private_networking = true
  region             = "${var.region}"
  size               = "512mb"
  ssh_keys           = ["${var.ssh_keys}"]
  tags               = ["${var.tags}"]
  volume_ids         = ["${digitalocean_volume.disk.id}"]

  provisioner "file" {
    source      = "${path.module}/secrets-keeper-dummy.bash"
    destination = "/root/secrets-keeper-dummy.bash"

    connection {
      type         = "ssh"
      bastion_host = "${var.bastion_host}"
      bastion_user = "coconut"
    }
  }

  provisioner "file" {
    source      = "${path.module}/secrets-keeper.service"
    destination = "/etc/systemd/system/secrets-keeper.service"

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
  depends_on = ["digitalocean_firewall.web"]
}

resource "digitalocean_firewall" "web" {
  name = "secrets-keeper"

  # the droplets to apply the rule to
  tags = ["${var.tags}"]

  inbound_rule = [
    {
      protocol    = "tcp"
      port_range  = "22"
      source_tags = ["${var.allow_inbound_tag}"]
    },
    {
      protocol    = "tcp"
      port_range  = "443"
      source_tags = ["${var.allow_inbound_tag}"]
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

resource "digitalocean_floating_ip" "secrets_keeper" {
  droplet_id = "${digitalocean_droplet.web.id}"
  region     = "${digitalocean_droplet.web.region}"
}

resource "digitalocean_domain" "secrets_keeper" {
  name       = "secrets.${var.host}"
  ip_address = "${digitalocean_floating_ip.secrets_keeper.ip_address}"
}
