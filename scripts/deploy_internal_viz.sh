#!/usr/bin/bash

service_name="viz"
service_port="8080"

image_name="dockersamples/visualizer:latest"


if [ -z "$(docker service ls | grep ${service_name})" ]; then
  echo "Service ${service_name} does not exist! Create using ${image_name} image..";

  docker service create                                                                                                              \
    --name "${service_name}"                                                                                                         \
    --network traefik                                                                                                                \
    --constraint=node.role==manager                                                                                                  \
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock,readonly                                               \
    --label 'traefik.enable=true'                                                                                                    \
    --label "traefik.http.services.${service_name}.loadbalancer.server.port=${service_port}"                                         \
    --label "traefik.http.routers.${service_name}.entrypoints=websecure"                                                             \
    --label "traefik.http.routers.${service_name}.rule=Host(\`vega.do.vadyalex.me\`) && PathPrefix(\`/${service_name}\`)"            \
    --label "traefik.http.routers.${service_name}.tls=true"                                                                          \
    --label "traefik.http.routers.${service_name}.tls.certresolver=letsencrypt"                                                      \
    --label 'traefik.http.middlewares.viz_auth.basicauth.users=root:$2y$10$c11GIIc4BP.tBHAD7p2hk.3TSsVLFrzLWudZQi2D5AsZH81VVefPO'    \
    --label 'traefik.http.middlewares.viz_auth.basicauth.removeheader=true'                                                          \
    --label "traefik.http.routers.${service_name}.middlewares=viz_auth"                                                              \
    --label "traefik.http.middlewares.${service_name}_https_redirect.redirectscheme.scheme=https"                                    \
    --label "traefik.http.routers.${service_name}_web.entrypoints=web"                                                               \
    --label "traefik.http.routers.${service_name}_web.rule=Host(\`vega.do.vadyalex.me\`) && PathPrefix(\`/${service_name}\`)"        \
    --label "traefik.http.routers.${service_name}_web.middlewares=${service_name}_https_redirect"                                    \
    --env CTX_ROOT=/viz                                                                                                              \
    ${image_name}

   echo 'Done!';
 
else
  echo "Updating ${service_name} using ${image_name}";

  docker service update --image "${image_name}" "${service_name}"

  echo 'Done!';
fi
