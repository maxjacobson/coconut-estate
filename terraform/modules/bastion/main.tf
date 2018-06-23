variable "region" {}

variable "ssh_keys" {
  type = "list"
}

variable "tags" {
  type = "list"
}

# Server to serve as the bastion
resource "digitalocean_droplet" "bastion" {
  image    = "ubuntu-16-04-x64"
  name     = "bastion"
  region   = "${var.region}"
  size     = "512mb"
  ssh_keys = ["${var.ssh_keys}"]
  tags     = ["${var.tags}"]

  provisioner "remote-exec" {
    script = "${path.module}/prepare-droplet.bash"
  }
}
