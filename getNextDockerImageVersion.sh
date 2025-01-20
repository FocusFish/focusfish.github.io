#!/usr/bin/env sh

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

bump_version () {
    uvms_version_part=$(echo "$latest_tag" | cut -d "." -f 4)
    uvms_version_part="${uvms_version_part:-0}"
    bumped_version=$((uvms_version_part+1))
    print_version "$bumped_version"
}

print_version () {
    echo -n "$dockerfile_version.${1:-1}"
}

latest_tag=$(git describe --tags --match="docker-image-*" --abbrev=0 HEAD 2>&1)

dockerfile_version=$(grep -m 1 -o ':.*' $SCRIPTPATH/Dockerfile | tr -d ':')

case $latest_tag in
    ("$dockerfile_version"*) bump_version;;
    (*) print_version;;
esac

