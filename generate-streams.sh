#!/bin/bash

dir="$1"

if [[ ! -d "$dir" || ! -r "$dir" ]]; then
  echo "Error: Invalid directory '$dir'"
  exit 1
fi

if [[ -f ".env" ]]; then
  source ".env"
fi

for file in "$dir"/*.txt; do
  filename=$(basename "$file")

  echo "Processing file: $filename"

  VVC=$(echo "$filename" | sed 's/\.txt$/.vvc/')

  ~/Documents/gpac/bin/gcc/gpac -i $file -o $dir/$VVC
done

echo "Done processing all files in '$dir'"
