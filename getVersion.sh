#!/usr/bin/env sh

group="${1:-fish.focus.uvms.docker}"
artifact="${2:-uvms-docker-wildfly-unionvms}"

curl -s https://central.sonatype.com/solrsearch/select\?q\=g:$group+AND+a:$artifact\&sort\=v+desc\&rows\=1 | grep -Po 'v.:.\K[^"]*'

