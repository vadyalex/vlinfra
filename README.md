# Vlinfra [Vlad's Infra]

Terraform provisioned Swarm Cluster on DigitalOcean.

Traefik service auto-reniwed certificates reverse proxying all incoming traffic either via HTTP or HTTPS 
to correspondend docker services within cluster.

To communicate to DigitalOcean API `DIGITALOCEAN_TOKEN` environment variable must contain valid API token.

Make and Docker must be installed locally to.

Terraform uses local state so must be refreshed via:

```
$ make whats-up
```

To spin up complete infrastucture:

```
$ make it
```
