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

  MP4=$(echo "$filename" | sed 's/\.266$/.mp4/')
  NHML=$(echo "$filename" | sed 's/\.266$/.nhml/')

  MP4Box -add $OUT_PATH/$filename -new $OUT_PATH/$MP4
  
  gpac -i $OUT_PATH/$MP4 -o $OUT_PATH/$NHML:pckp
done

echo "Done processing all files in '$dir'"
