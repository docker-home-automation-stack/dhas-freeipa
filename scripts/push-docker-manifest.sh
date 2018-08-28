#!/bin/bash
set -e

if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
  exit 0
fi

echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
sleep $[ ( $RANDOM % 10 )  + 1 ]s

for VARIANT in $( docker images | grep '^homeautomationstack/*' | grep -v "<none>" | grep -P ' dev|beta|latest ' | awk '{print $2}' | uniq | sort ); do
  echo "Creating manifest file homeautomationstack/dhas-freeipa:${VARIANT} ..."
  docker manifest create homeautomationstack/dhas-freeipa:${VARIANT} \
    homeautomationstack/dhas-freeipa-amd64_linux:${VARIANT} \
    homeautomationstack/dhas-freeipa-i386_linux:${VARIANT} \
    homeautomationstack/dhas-freeipa-arm32v6_linux:${VARIANT} \
    homeautomationstack/dhas-freeipa-arm64v8_linux:${VARIANT}
  docker manifest annotate homeautomationstack/dhas-freeipa:${VARIANT} homeautomationstack/dhas-freeipa-arm32v6_linux:${VARIANT} --os linux --arch arm --variant v6
  docker manifest annotate homeautomationstack/dhas-freeipa:${VARIANT} homeautomationstack/dhas-freeipa-arm64v8_linux:${VARIANT} --os linux --arch arm64 --variant v8
  docker manifest inspect homeautomationstack/dhas-freeipa:${VARIANT}

  echo "Pushing manifest homeautomationstack/dhas-freeipa:${VARIANT} to Docker Hub ..."
  docker manifest push homeautomationstack/dhas-freeipa:${VARIANT}

  echo "Requesting current manifest from Docker Hub ..."
  docker run --rm mplatform/mquery homeautomationstack/dhas-freeipa:${VARIANT}
done

exit 0
