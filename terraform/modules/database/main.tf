variable "region" {}

variable "ssh_keys" {
  type = "list"
}

variable "tag" {}

resource "digitalocean_volume" "database" {
  description = "A persistent volume to store the database's data on"
  name        = "database"
  region      = "${var.region}"
  size        = "20"

  # TODO: do the auto-mounting thing
}

# TODO: add a prepare-droplet.bash to install docker and use it to run postgres
resource "digitalocean_droplet" "database" {
  image              = "ubuntu-18-04-x64"
  name               = "database"
  private_networking = true
  region             = "${var.region}"
  size               = "512mb"             # N.B. this is skimpy because I'm cheap and also no one uses the site at the moment
  ssh_keys           = ["${var.ssh_keys}"]
  tags               = ["${var.tag}"]

  volume_ids = ["${digitalocean_volume.database.id}"]
}
