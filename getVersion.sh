#!/usr/bin/env sh

group="${1:-fish.focus.uvms.docker}"
artifact="${2:-uvms-docker-wildfly-unionvms}"

curl -s https://search.maven.org/solrsearch/select\?q\=g:$group+AND+a:$artifact | grep -Po 'latestVersion.:.\K[^"]*'

