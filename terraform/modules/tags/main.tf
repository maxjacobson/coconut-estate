resource "digitalocean_tag" "secrets_keeper" {
  name = "secrets-keeper"
}

resource "digitalocean_tag" "bastion" {
  name = "bastion"
}

resource "digitalocean_tag" "website" {
  name = "website"
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
