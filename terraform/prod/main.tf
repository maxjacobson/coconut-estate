variable "do_token" {}

provider "digitalocean" {
  token   = "${var.do_token}"
  version = "~> 0.1"
}

module "secrets_keeper" {
  source = "../modules/secrets_keeper"
  region = "nyc1"

  ssh_keys = [
    "${digitalocean_ssh_key.max_mac_mini.fingerprint}",
    "${digitalocean_ssh_key.max_xps_13.fingerprint}",
  ]

  tags = ["${digitalocean_tag.secrets_keeper.id}"]
}

resource "digitalocean_ssh_key" "max_mac_mini" {
  name       = "Max's SSH Key on Mac Mini"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDxEZNLAi2YGGsgjyycKM0DMrmV052ofZ18Br65K1XR3ocSEXgbs8Q3wpTouIMf/RJK4toecNJJIHh2Iz7hucEribLFvap+c8BeL7i09tq0NyuEMR5JYm/NGA48sMZk18Xenwy7K0r67pyu9MahWveX/TghXR5y3bdSQO7DuqgPVSidZL8OnD4damUQ5p5J6kAV65u5VKXZU1vKTECpjBvCBzHQhIQIWAnJMk5ihyKgyBw9BRPJPio+6qzkOvmyn58hUo0KrQFtezOJSwHkBYXyEnBLax1m1WzdIZbCqgv0v+aUS6cwQqnoOFtNgjoS4x+CNVTXQWjwtfHap5c8++MvaguMgrgzmwCZqiAyOs9RLIiPVhnyogTNIfT0y87uO3KjeGOwxDwrKCTmSu7orsYBU7nuMn6A9Njpiw+GIAlH0F9GSSb7nwq2nQZUclvuCm9ar7snVGV2mIeUQ6A5aoXSeFhfp48Vjs1V0FFy8lw4wLcQGGYReaMb8g0XeNRDYi312ryzm9BPyrAD7VYkGMIRP5Muub/plhw9TWUpte14UP+SbbLsTP0d769C6fV6wbvA8FAW5AQAhfk6lf5YLlLOIXABLSbPCJw94VOgGYrk264hxtcC/jTHwAJnAGTrOubp/9TpJj3EWZfnNHFGNX19GibxJFf7ZtCzw9PACyctGQ== max@hardscrabble.net"
}

resource "digitalocean_ssh_key" "max_xps_13" {
  name       = "Max's SSH Key on XPS 13"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQChUfzpCK1Sl7yjggATFW6Xz9r+FprbUKHFGYRnsDGo0CIB31+P80r2lpwB/vrVl7sRuhS/nUX78k+BwSOHHk84NufdKnExMj2Fef//KlbpMZTh4VcHne3PcGyDjb/K9NBvWN2ytst2RNrcPnKmnh2z4C8WYorknc+4ddSXWRWxacongqeCsUUPQC/QtTfyUXX8WsHrfPwcuZM1e3FyNXj7YZ9MHEhViTRtkS1PUgVdb2lBaH+dS3N+ORH8gJbO2WZKCirpxXsQsizgOWZZFUk5RQ8JyUQn8fdN+rCG6KBJ0Ecs1Bckr/t3Y41q8/G5e/F549Qy1mv90WDHNDU1sMEv/N68hgw7mDg+MEn9A3wI2C+66zqY306P4J0efEWruGaEQgDOzluvYBdpf1ejq+BS4eH8LWcQz+Ol3I1yC2Z0/hussckfpDLCJSpJ/7QcUoFaXxblzEkiVxcq294sLrMt6rLSJ77kT+e7SlaghDWKqzgRSXghLmPf8XaOULEljGE6FoP2lMAZ/AcIKQpPg0cO5YpcsyXnyTL/nguTT79UiPF9CYfI5XX/adJsmtZFFiIx+DbyOl4ttZguVhYhfSQTADGPOV+/Qz3d1CWN4kHqCmD3oVMRCCDUQDXPDVdZPyX/Ue2oyNtps1YS83KYqDQXvZdSdM773+oVlEtE5k6A+Q== max@hardscrabble.net"
}

resource "digitalocean_tag" "secrets_keeper" {
  name = "secrets-keeper"
}
