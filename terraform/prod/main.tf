terraform {
  # N.B. this is actually a Digital Ocean "space" pretending to be an S3 bucket
  backend "s3" {
    bucket   = "coconut-estate-tfstate"      # name of space
    endpoint = "ams3.digitaloceanspaces.com" # storing in amsterdam
    key      = "prod/terraform.tfstate"      # file in space to store state
    region   = "us-east-1"                   # N.B. This is not real

    # Disable a few s3 things
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_get_ec2_platforms      = true
    skip_metadata_api_check     = true
  }
}

variable "do_token" {}

variable "host" {
  default = "coconutestate.top"
}

variable "ops_email" {
  default = "max@hardscrabble.net"
}

variable "region" {
  default = "nyc1"
}

provider "digitalocean" {
  token   = "${var.do_token}"
  version = "1.0.2"
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

  allow_inbound_http_tags = [
    "${module.tags.api_name}",     # Because it needs access to secrets to boot the API
    "${module.tags.bastion_name}", # So we can tunnel local requests through the bastion
  ]

  allow_inbound_ssh_tag = "${module.tags.bastion_name}"
  bastion_host          = "${module.bastion.host}"
  host                  = "${var.host}"
  region                = "${var.region}"
  ssh_keys              = ["${module.ssh_keys.all}"]
  tag                   = "${module.tags.secrets_keeper_id}"
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

  allow_inbound_ssh_tag      = "${module.tags.bastion_name}"
  allow_inbound_database_tag = "${module.tags.api_name}"
  bastion_host               = "${module.bastion.host}"
  host                       = "${var.host}"
  ops_email                  = "${var.ops_email}"
  region                     = "${var.region}"
  ssh_keys                   = ["${module.ssh_keys.all}"]
  website_tag                = "${module.tags.website_id}"

  # TODO: separate this all out so that we can just pass in a single tag
  tags = [
    "${module.tags.website_id}",
    "${module.tags.database_id}",
  ]
}

module "api" {
  source = "../modules/api"

  bastion_host = "${module.bastion.host}"
  host         = "${var.host}"
  region       = "${var.region}"
  ssh_keys     = ["${module.ssh_keys.all}"]
  tag          = "${module.tags.api_id}"
}

module "database" {
  source = "../modules/database"

  region   = "${var.region}"
  ssh_keys = ["${module.ssh_keys.all}"]
  tag      = "${module.tags.api_id}"
}
