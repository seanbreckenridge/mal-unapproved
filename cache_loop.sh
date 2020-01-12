#!/usr/bin/env sh
#
# Run by GNU-screen in the background
# every hour, saves the currently
# unapproved entries to ./unapproved.json
# Runs cache_name.py to cache names/types
# for those entries

THIS_DIR=$(dirname $(realpath "$0"))

while true; do
  cd "${HOME}/.mal-id-cache/repo" && pipenv run mal_id_cache --unapproved json
  cp "${HOME}/.mal-id-cache/repo/unapproved_mal_ids.json" "${THIS_DIR}/unapproved.json"
  python3 "${THIS_DIR}/cache_names.py"
  date
  sleep 3600
done
