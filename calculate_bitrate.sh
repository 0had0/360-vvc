#!/bin/bash

# Set the folder path (replace with your actual path)
folder_path="$1"

# Output file name (change if desired)
output_file="video_bitrates.txt"

# Check if folder exists
if [ ! -d "$folder_path" ]; then
  echo "Error: Folder '$folder_path' does not exist."
  exit 1
fi

# Loop through all .mp4 files in the folder
for file in "$folder_path"/*.mp4; do
  # Extract filename without path
  filename=$(basename "$file")

  # Get bitrate using ffmpeg
  text=$(ffmpeg -i "$file" 2>&1 | grep bitrate)
  IFS=", " read -r _ _ _ _ _ bitrate _ <<< "$text"


  # Check if bitrate extraction was successful
  if [ -z "$bitrate" ]; then
    echo "Error: Could not extract bitrate for '$filename'" >&2
  else
    # Write filename and bitrate to output file
    echo "$filename: $bitrate kbps" >> "$output_file"
  fi
done

# Print confirmation message
echo "Bitrate information saved to '$output_file'"

