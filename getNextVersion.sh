#!/usr/bin/env sh

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

bump_version () {
    doc_version_part=$(echo "$latest_tag" | cut -d "." -f 4)
    doc_version_part="${doc_version_part:-0}"
    bumped_version=$((doc_version_part+1))
    print_version "$bumped_version"
}

print_version () {
    echo -n "$input_version.${1:-1}"
}

if [ "$1" = "docker" ]; then
    input_version=$(grep -m 1 -o ':.*' $SCRIPTPATH/Dockerfile | tr -d ':')
    latest_tag=$(git tag -l --sort=-taggerdate 'docker-image-*' | head -n1 | sed 's/docker-image-//' 2>&1)
else
    input_version="$2"
    latest_tag=$(git tag -l --sort=-taggerdate | grep -v 'docker' | head -n1 2>&1)
fi

case $latest_tag in
    ("$input_version"*) bump_version;;
    (*) print_version;;
esac

