#!/usr/bin/bash

SERVICE_NAME="whoami"
SERVICE_PORT="80"

IMAGE_NAME="traefik/whoami"

if [ -z "$(docker service ls | grep ${SERVICE_NAME})" ]; then
  echo "Service ${SERVICE_NAME} does not exist! Create using ${IMAGE_NAME} image..";

  docker service create                                                                               \
    --name "${SERVICE_NAME}"                                                                          \
    --network traefik                                                                                 \
    --label traefik.enable=true                                                                       \
    --label "traefik.http.services.${SERVICE_NAME}.loadbalancer.server.port=${SERVICE_PORT}"          \
    --label "traefik.http.routers.${SERVICE_NAME}.rule=Host(\\\`${SERVICE_NAME}.app.vadyalex.me\\\`)" \
    --label "traefik.http.routers.${SERVICE_NAME}.entrypoints=websecure"                              \
    --label "traefik.http.routers.${SERVICE_NAME}.tls=true"                                           \
    --label "traefik.http.routers.${SERVICE_NAME}.tls.certresolver=letsencrypt"                       \
    ${IMAGE_NAME}

   echo 'Done!';
 
else
  echo "Updating ${SERVICE_NAME} using ${IMAGE_NAME}";

  docker service update --image "${IMAGE_NAME}" "${SERVICE_NAME}"

  echo 'Done!';
fi

