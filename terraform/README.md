# Terraform

## Setup

Create a `terraform/prod/terraform.tfvars` file which looks like:

```text
do_token = "1234"
```

## Usage

```shell
cd terraform/prod
terraform init
terraform apply
```

## Re-provisioning a resource

If you want to force terraform to reprovision something, you can taint it and then apply:

```shell
terraform taint -module secrets_keeper digitalocean_droplet.web
terraform apply
```
