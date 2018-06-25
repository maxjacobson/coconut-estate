variable "do_token" {}

variable "host" {
  default = "coconutestate.top"
}

variable "region" {
  default = "nyc1"
}

provider "digitalocean" {
  token   = "${var.do_token}"
  version = "~> 0.1"
}

provider "template" {
  version = "~> 1.0"
}

module "ssh_keys" {
  source = "../modules/ssh_keys"
}

module "tags" {
  source = "../modules/tags"
}

module "secrets_keeper" {
  source = "../modules/secrets_keeper"

  allow_inbound_tag = "${module.tags.bastion_name}"
  bastion_host      = "${module.bastion.host}"
  host              = "${var.host}"
  region            = "${var.region}"
  ssh_keys          = ["${module.ssh_keys.all}"]
  tags              = ["${module.tags.secrets_keeper_id}"]
}

module "bastion" {
  source = "../modules/bastion"

  host     = "${var.host}"
  region   = "${var.region}"
  ssh_keys = ["${module.ssh_keys.all}"]
  tags     = ["${module.tags.bastion_id}"]
}

module "website" {
  source = "../modules/website"

  allow_inbound_tag = "${module.tags.bastion_name}"
  bastion_host      = "${module.bastion.host}"
  host              = "${var.host}"
  region            = "${var.region}"
  ssh_keys          = ["${module.ssh_keys.all}"]
  tags              = ["${module.tags.website_id}"]
}
