#!/bin/bash

# Check for input video file path
if [[ $# -ne 1 ]]; then
   echo "Error: Please provide the path to the video file as input."
   exit 1
fi

video_file="$1"

# Extract video name without extension
video_name="${video_file%.*}"

# Save ffprobe output
echo $(ffprobe -i "$video_file") > "$video_name.ffprobe"

# Extract width, height, and frame rate from ffprobe output
width=$(grep stream=width "$video_name.ffprobe" | awk '{print $2}')
height=$(grep stream=height "$video_name.ffprobe" | awk '{print $2}')
frame_rate=$(grep r_frame_rate "$video_name.ffprobe" | awk '{print $2}')

# Calculate new width and height as multiples of 128
new_width=$(( width + 127 )) & ~127
new_height=$(( height + 127 )) & ~127

# Resize video using ffmpeg and output to a YUV file
ffmpeg -i "$video_file" -vf "scale=$new_width:$new_height" -c:v rawvideo -pix_fmt yuv420p -y $frame_rate "$video_name_${new_width}x${new_height}_$frame_rate.yuv"
