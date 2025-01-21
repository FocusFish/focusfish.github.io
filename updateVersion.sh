#!/usr/bin/env sh

variable="${1}"
version="${2}"
file="${3}"

sed -i 's|'"$variable"':.*$|'"$variable"': '"$version"'|' "${file}"

