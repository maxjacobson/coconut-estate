variable "do_token" {}

variable "region" {
  default = "nyc1"
}

provider "digitalocean" {
  token   = "${var.do_token}"
  version = "~> 0.1"
}

module "ssh_keys" {
  source = "../modules/ssh_keys"
}

module "tags" {
  source = "../modules/tags"
}

module "secrets_keeper" {
  source = "../modules/secrets_keeper"

  region   = "${var.region}"
  ssh_keys = ["${module.ssh_keys.all}"]
  tags     = ["${module.tags.secrets_keeper_id}"]
}

module "bastion" {
  source = "../modules/bastion"

  region   = "${var.region}"
  ssh_keys = ["${module.ssh_keys.all}"]
  tags     = ["${module.tags.bastion_id}"]
}
