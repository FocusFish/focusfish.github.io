#!/usr/bin/env sh

variable="${1}"
version="${2}"

sed -i 's|'"$variable"':.*$|'"$variable"': '"$version"'|' mkdocs.yml

