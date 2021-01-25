terraform {
  required_version = ">= 0.14.5"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.4.0"
    }
  }
}

provider "digitalocean" {
  # Make sure DIGITALOCEAN_TOKEN env variable is set
  #export DIGITALOCEAN_TOKEN="Your API TOKEN"
}

data "template_file" "user_data" {
  template = file("cloud-config.yml")
}

resource "digitalocean_droplet" "vega" {
  size               = "s-1vcpu-1gb"
  region             = "ams3"
  image              = "debian-10-x64"
  name               = "vega"
  tags               = ["tf"]
  monitoring         = true
  ipv6               = false
  private_networking = true
  ssh_keys           = [ "ec:32:ca:0e:fa:3d:fb:52:7f:fa:20:5a:77:a8:ed:6a" ]
}