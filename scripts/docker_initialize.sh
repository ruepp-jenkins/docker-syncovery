#!/bin/bash
set -e
echo "Initialize docker"

echo ${DOCKER_API_PASSWORD} | docker login --username ${DOCKER_USERNAME} --password-stdin
docker buildx install

set +e
echo "Adding buildx builder - this could throw a 'wanted' error if it already exist"
docker buildx create --name mybuilder --bootstrap --use
set -e
