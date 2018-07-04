resource "digitalocean_tag" "secrets_keeper" {
  name = "secrets-keeper"
}

resource "digitalocean_tag" "bastion" {
  name = "bastion"
}

resource "digitalocean_tag" "website" {
  name = "website"
}

resource "digitalocean_tag" "api" {
  name = "api"
}

resource "digitalocean_tag" "database" {
  name = "database"
}

output "secrets_keeper_id" {
  value = "${digitalocean_tag.secrets_keeper.id}"
}

output "secrets_keeper_name" {
  value = "${digitalocean_tag.secrets_keeper.name}"
}

output "bastion_id" {
  value = "${digitalocean_tag.bastion.id}"
}

output "bastion_name" {
  value = "${digitalocean_tag.bastion.name}"
}

output "website_id" {
  value = "${digitalocean_tag.website.id}"
}

output "website_name" {
  value = "${digitalocean_tag.website.name}"
}

output "api_id" {
  value = "${digitalocean_tag.api.id}"
}

output "api_name" {
  value = "${digitalocean_tag.api.name}"
}

output "database_id" {
  value = "${digitalocean_tag.database.id}"
}

output "database_name" {
  value = "${digitalocean_tag.database.name}"
}
