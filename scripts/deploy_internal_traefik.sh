#!/usr/bin/bash

service_name="traefik"
service_port="999"

image_name="traefik:v2.5"


if [ -z "$(docker service ls | awk -F' ' '{print $2}' | grep ${service_name})" ]; then
  echo "Service ${service_name} does not exist! Create using ${image_name} image..";

  mkdir -p /data/volumes/traefik/acme

  docker service create                                                                                                                                   \
    --name "${service_name}"                                                                                                                              \
    --constraint=node.role==manager                                                                                                                       \
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock,readonly                                                                    \
    --network traefik                                                                                                                                     \
    --publish 80:80                                                                                                                                       \
    --publish 443:443                                                                                                                                     \
    --label 'traefik.enable=true'                                                                                                                         \
    --label "traefik.http.services.${service_name}.loadbalancer.server.port=${service_port}"                                                              \
    --label "traefik.http.routers.${service_name}.entrypoints=websecure"                                                                                  \
    --label "traefik.http.routers.${service_name}.rule=Host(\`vega.do.vadyalex.me\`) && (PathPrefix(\`/dashboard\`) || PathPrefix(\`/api\`))"             \
    --label "traefik.http.routers.${service_name}.tls=true"                                                                                               \
    --label "traefik.http.routers.${service_name}.tls.certresolver=letsencrypt"                                                                           \
    --label "traefik.http.routers.${service_name}.service=api@internal"                                                                                   \
    --label 'traefik.http.middlewares.the_auth.basicauth.users=root:$2y$10$c11GIIc4BP.tBHAD7p2hk.3TSsVLFrzLWudZQi2D5AsZH81VVefPO'                         \
    --label 'traefik.http.middlewares.the_auth.basicauth.removeheader=true'                                                                               \
    --label "traefik.http.routers.${service_name}.middlewares=the_auth"                                                                                   \
    --label 'traefik.http.middlewares.the_https_redirect.redirectscheme.scheme=https'                                                                     \
    --label "traefik.http.routers.${service_name}_web.entrypoints=web"                                                                                    \
    --label "traefik.http.routers.${service_name}_web.rule=Host(\`vega.do.vadyalex.me\`) && (PathPrefix(\`/dashboard\`) || PathPrefix(\`/api\`))"         \
    --label "traefik.http.routers.${service_name}_web.middlewares=the_https_redirect"                                                                     \
    ${image_name}                                                                                                                                         \
    --providers.docker=true                                                                                                                               \
    --providers.docker.swarmMode=true                                                                                                                     \
    --providers.docker.exposedByDefault=false                                                                                                             \
    --entrypoints.web=true                                                                                                                                \
    --entrypoints.web.address=:80                                                                                                                         \
    --entrypoints.websecure=true                                                                                                                          \
    --entrypoints.websecure.address=:443                                                                                                                  \
    --certificatesresolvers.letsencrypt=true                                                                                                              \
    --certificatesresolvers.letsencrypt.acme.email=vadyalex@gmail.com                                                                                     \
    --certificatesresolvers.letsencrypt.acme.httpchallenge=true                                                                                           \
    --certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web                                                                                 \
    --api.dashboard=true


   echo 'Done!';
 
else
  echo "Updating ${service_name} using ${image_name}";

  docker service update --image "${image_name}" "${service_name}"

  echo 'Done!';
fi
