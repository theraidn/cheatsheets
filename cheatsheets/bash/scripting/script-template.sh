#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage(){
  cat <<EOF
Usage: ${0##*/} -f <file>
EOF
}

log(){ printf "%s: %s\n" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" >&2; }

cleanup(){
  # reversible cleanup actions
  :
}

trap cleanup EXIT

file=""
while getopts ":f:h" opt; do
  case "$opt" in
    f) file="$OPTARG" ;;
    h) usage; exit 0 ;;
    *) usage; exit 2 ;;
  esac
done

if [[ -z "${file:-}" ]]; then
  usage
  exit 2
fi

log "Processing $file"

# idempotent example: create directory if missing
mkdir -p "${file%/*}"

exit 0
