#!/usr/bin/bash

SERVICE_NAME="$1"

if [ -z "${SERVICE_NAME}" ]; then
  echo "First argument must be app name: deploy_app.sh APP_NAME IMAGE_NAME";
  exit 1
fi


IMAGE_NAME="$2"

if [ -z "${IMAGE_NAME}" ]; then
  echo "Second argument must image name: deploy_app.sh ${SERVICE_NAME} IMAGE_NAME";
  exit 1
fi


if [ -z "$(docker service ls | grep ${SERVICE_NAME})" ]; then
  echo "Service ${SERVICE_NAME} does not exist! Create using ${IMAGE_NAME} image..";

  docker service create                                                                               \
    --name "${SERVICE_NAME}"                                                                          \
    --network traefik                                                                                 \
    --label traefik.enable=true                                                                       \
    --label "traefik.http.services.${SERVICE_NAME}.loadbalancer.server.port=80"                       \
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

