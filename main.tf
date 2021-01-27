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
  tags               = ["tf", "swarm", "manager"]
  monitoring         = true
  ipv6               = false
  private_networking = true
  ssh_keys           = [ "ec:32:ca:0e:fa:3d:fb:52:7f:fa:20:5a:77:a8:ed:6a" ]
  user_data          = data.template_file.user_data.rendered

  connection {
    type = "ssh"
    user = "root"
    private_key = file("/root/.ssh/id_rsa")
    host = self.ipv4_address
    timeout = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ -z \"$(docker info | grep CPUs)\" ]; do echo 'Waiting for cloud init finishing initializing Docker..'; sleep 10; done",
      "echo 'Initializing Docker Swarm..'",
      "docker swarm init --advertise-addr ${self.ipv4_address_private}",
      "echo 'Create traefik overlay network..'",
      "docker network create --driver=overlay traefik",
      "echo 'Create traefik service..'",
      "docker service create --name traefik --constraint=node.role==manager --publish 80:80 --publish 443:443 --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock,readonly --network traefik traefik:v2.4 --providers.docker=true --providers.docker.swarmMode=true --providers.docker.exposedByDefault=false --entrypoints.web.address=:80 --entrypoints.websecure.address=:443 --certificatesresolvers.letsencrypt.acme.email=vadyalex@gmail.com --certificatesresolvers.letsencrypt.acme.storage=acme.json --certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web",
      "echo 'All set!",
    ]
  }

}

output "vega_public_ip" {
  value = digitalocean_droplet.vega.ipv4_address
}

output "vega_private_ip" {
  value = digitalocean_droplet.vega.ipv4_address_private
}

resource "digitalocean_record" "vega" {
  domain = "vadyalex.me"
  type   = "A"
  name   = "vega.do"
  value  = digitalocean_droplet.vega.ipv4_address
  ttl    = 300

  depends_on = [digitalocean_droplet.vega]
}

resource "digitalocean_record" "app" {
  domain = "vadyalex.me"
  type   = "A"
  name   = "*.app"
  value  = digitalocean_droplet.vega.ipv4_address
  ttl    = 300

  depends_on = [digitalocean_droplet.vega]
}
