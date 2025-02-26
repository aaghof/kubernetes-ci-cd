#!/bin/bash

#Retrieve the latest git commit hash
BUILD_TAG=`git rev-parse --short HEAD`

#Build the docker image
docker build -t 127.0.0.1:30400/kr8sswordz:$BUILD_TAG -f applications/kr8sswordz-pages/Dockerfile applications/kr8sswordz-pages

#Setup the proxy for the registry
docker stop socat-registry; docker rm socat-registry; docker run -d -e "REG_IP=`minikube ip`" -e "REG_PORT=30401" --name socat-registry -p 30401:5000 socat-registry

echo "5 second sleep to make sure the registry is ready"
sleep 5;

#Push the images
docker push 127.0.0.1:30400/kr8sswordz:$BUILD_TAG

#Stop the registry proxy
docker stop socat-registry

# Create the deployment and service for the front end aka kr8sswordz
sed 's#127.0.0.1:30400/kr8sswordz:$BUILD_TAG#127.0.0.1:30400/kr8sswordz:'$BUILD_TAG'#' applications/kr8sswordz-pages/k8s/deployment.yaml | kubectl apply -f -
