#!/bin/bash
# uglifies the css and puts each file into ./public/css

THIS_DIR="$(dirname "${BASH_SOURCE[0]}")"
PUBLIC_DIR="${THIS_DIR}/public"
CSS_OUTPUT_DIR="${PUBLIC_DIR}/css"

# remove CSS output dir if it exists
[ -d "$CSS_OUTPUT_DIR" ] && rm -rf "$CSS_OUTPUT_DIR"
mkdir -p "$CSS_OUTPUT_DIR"

# re-create uglified CSS
while IFS= read -r -d '' raw_css_file; do
	base_file=$(basename "$raw_css_file")
	uglifycss "$raw_css_file" --output "${CSS_OUTPUT_DIR}/${base_file}"
done < <(find "${PUBLIC_DIR}/raw_css" -type f -print0 -name "*.css")
