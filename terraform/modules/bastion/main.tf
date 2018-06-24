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
  image              = "ubuntu-16-04-x64"
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

resource "digitalocean_floating_ip" "bastion" {
  droplet_id = "${digitalocean_droplet.bastion.id}"
  region     = "${digitalocean_droplet.bastion.region}"
}

resource "digitalocean_domain" "bastion" {
  name       = "bastion.${var.host}"
  ip_address = "${digitalocean_floating_ip.bastion.ip_address}"
}

output "host" {
  value = "${digitalocean_domain.bastion.id}"
}
