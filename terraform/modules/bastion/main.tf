variable "region" {}

variable "host" {}

variable "ssh_keys" {
  type = "list"
}

variable "tags" {
  type = "list"
}

# Server to serve as the bastion
resource "digitalocean_droplet" "bastion" {
  image              = "ubuntu-18-04-x64"
  name               = "bastion"
  private_networking = true
  region             = "${var.region}"
  size               = "512mb"
  ssh_keys           = ["${var.ssh_keys}"]
  tags               = ["${var.tags}"]

  provisioner "remote-exec" {
    script = "${path.module}/prepare-droplet.bash"
  }
}

resource "digitalocean_domain" "bastion" {
  name       = "bastion.${var.host}"
  ip_address = "${digitalocean_droplet.bastion.ipv4_address}"
}

output "host" {
  value = "${digitalocean_domain.bastion.id}"
}
