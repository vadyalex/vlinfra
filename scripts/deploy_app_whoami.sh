#!/usr/bin/bash

service_name="whoami"
service_port="80"

image_name="traefik/whoami"

if [ -z "$(docker service ls | grep ${service_name})" ]; then
  echo "Service ${service_name} does not exist! Create using ${image_name} image..";

  docker service create                                                                               \
    --name "${service_name}"                                                                          \
    --network traefik                                                                                 \
    --label 'traefik.enable=true'                                                                     \
    --label "traefik.http.services.${service_name}.loadbalancer.server.port=${service_port}"          \
    --label "traefik.http.routers.${service_name}.entrypoints=websecure"                              \
    --label "traefik.http.routers.${service_name}.rule=Host(\`${service_name}.app.vadyalex.me\`)"     \
    --label "traefik.http.routers.${service_name}.tls=true"                                           \
    --label "traefik.http.routers.${service_name}.tls.certresolver=letsencrypt"                       \
    --label 'traefik.http.middlewares.https_redirect.redirectscheme.scheme=https'                     \
    --label "traefik.http.routers.${service_name}_web.entrypoints=web"                                \
    --label "traefik.http.routers.${service_name}_web.rule=Host(\`${service_name}.app.vadyalex.me\`)" \
    --label "traefik.http.routers.${service_name}_web.middlewares=https_redirect"                     \
    ${image_name}

   echo 'Done!';
 
else
  echo "Updating ${service_name} using ${image_name}";

  docker service update --image "${image_name}" "${service_name}"

  echo 'Done!';
fi

