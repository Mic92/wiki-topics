#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "USAGE: $0 github-user/repo-name gittag" >&2
    echo "i.e.: $0 Mic92/wiki-topics assets" >&2
    exit 1
fi

REMOTE="$1"
TAG="$2"

set  -x

DIR="$(mktemp -d)"
trap 'rm -rf -- "$DIR"' EXIT

upload_dump() {
    curl "$1" | zcat | grep -v $'[^\t\r -~]' | shuf | zstd > "${DIR}/${2}"
    gh release upload --clobber --repo "$REMOTE" "${TAG}" "${DIR}/${2}"
    rm -f "${DIR}/${2}"
}

upload_dump 'https://dumps.wikimedia.org/scowiki/latest/scowiki-latest-all-titles-in-ns0.gz' "scowiki-latest-all-titles-in.zstd"
upload_dump 'https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-all-titles-in-ns0.gz' "en-latest-all-titles-in.zstd"
