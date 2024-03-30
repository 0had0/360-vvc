#!/bin/bash

# if [ "$#" -ne 1 ]; then
#     echo "Usage: $0 <bitstream.266>"
#     exit 1
# fi

# # Ensure the .env file exists and source it
# # ENV_FILE=".env"
# # if [ -f "$ENV_FILE" ]; then
# #     echo `ls .en*`
# #     source $ENV_FILE
# # else
# #     echo "Error: .env file not found."
# #     exit 2
# # fi

# BITSTREAM="$1"



dir="$1"

if [[ ! -d "$dir" || ! -r "$dir" ]]; then
  echo "Error: Invalid directory '$dir'"
  exit 1
fi

if [[ -f ".env" ]]; then
  source ".env"
fi

for file in "$dir"/*.266; do
  filename=$(basename "$file")

  echo "Processing file: $filename"

  MP4=$(echo "$file" | sed 's/\.266$/.mp4/')
  NHML=$(echo "$file" | sed 's/\.266$/.nhml/')

  ~/Documents/gpac/bin/gcc/MP4Box -add $file -new $MP4
  
  ~/Documents/gpac/bin/gcc/gpac -i $MP4 -o $NHML:pckp
done

echo "Done processing all files in '$dir'"
