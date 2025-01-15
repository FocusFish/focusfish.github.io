#!/usr/bin/env sh

dev_address="--dev-addr=0.0.0.0:8000"

if [[ "$1" == "mike" && "$2" == "serve" ]]; then
    set -- "$@" "$dev_address"
fi

exec "$@"
