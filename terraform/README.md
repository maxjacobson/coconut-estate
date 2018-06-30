# Terraform

## Setup

Visit https://cloud.digitalocean.com/settings/api/tokens and create a personal access token.

Create a `terraform/prod/terraform.tfvars` file which looks like:

```text
do_token = "1234"
```

On that same page, create a spaces access key & secret key pair.

Create a `terraform/prod/secret-backend-config.tvars` file which looks like:

```text
access_key = "1234"

secret_key = "1234"
```

## Usage

```shell
cd terraform/prod
terraform init -backend-config=./secret-backend-config.tfvars
terraform apply
```

## Re-provisioning a resource

If you want to force terraform to reprovision something, you can taint it and then apply:

```shell
terraform taint -module secrets_keeper digitalocean_droplet.web
terraform apply
```
