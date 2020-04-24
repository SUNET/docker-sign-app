#!/bin/bash

echo Deploying docker containter upload-sig-app
docker run -d --name upload-sig-app --restart=always \
  -p 8080:8080 -p 8009:8009 \
  -e "SPRING_CONFIG_ADDITIONAL_LOCATION=/opt/upload-sig-app/" \
  -v /etc/localtime:/etc/localtime:ro \
  -v /opt/docker/upload-sign-sp:/opt/upload-sig-app \
  upload-sign-sp

echo Done!
