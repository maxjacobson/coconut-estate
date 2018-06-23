variable "region" {}

variable "ssh_keys" {
  type = "list"
}

variable "tags" {
  type = "list"
}

resource "digitalocean_volume" "disk" {
  description = "A persistent volume to store secrets on"
  name        = "secrets-keeper"
  region      = "${var.region}"
  size        = "1"
}

# Server to run the secrets keeper web service on
resource "digitalocean_droplet" "web" {
  image      = "ubuntu-16-04-x64"
  name       = "secrets-keeper"
  region     = "${var.region}"
  size       = "512mb"
  ssh_keys   = ["${var.ssh_keys}"]
  tags       = ["${var.tags}"]
  volume_ids = ["${digitalocean_volume.disk.id}"]

  provisioner "remote-exec" {
    script = "${path.module}/prepare-droplet.sh"
  }
}
