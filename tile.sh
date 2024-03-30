#!/bin/bash

n=3
m=3
width=1920
height=1080
frame_rate=30
output_path="tiles"
INPUT=""

while getopts ":i:d:o:" opt; do
  case $opt in
    i) INPUT="$OPTARG" ;;
    d) IFS='x' read -ra dims <<< "$OPTARG"
       n=${dims[0]}
       m=${dims[1]} ;;
    o) output_path="$OPTARG" ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND-1))

if [ -z "$INPUT" ]; then
  echo "Usage: $0 <filename_widthxheight_framerate.yuv>"
  exit 1
fi

BASENAME=$(basename "$INPUT" .yuv)
IFS='_' read -r name dimensions framerate <<< "$BASENAME"
IFS='x' read -r width height <<< "$dimensions"

tile_width=$((width / n))
tile_height=$((height / m))
tile_width=$((tile_width / 128 * 128))
tile_height=$((tile_height / 128 * 128))

echo "Processing file: $BASENAME"
echo "Width: $width, Height: $height, FrameRate: $framerate"
echo "Tiling into ( $((n))x$((m)) ) $((n * m)) tiles each with, Width: $tile_width Height: $tile_height"

rm "$output_path/subpicture.cfg"
touch "$output_path/subpicture.cfg"

tile_idx=0
count=0

for ((i=0; i<n; i++)); do
  for ((j=0; j<m; j++)); do
    tile_idx=$((++count))
    x=$((i * tile_width))
    y=$((j * tile_height))
    
    echo $x, $y, $tile_width, $tile_height

    printf -v padded_idx "%02d" "$tile_idx"

    tile_path="$output_path/${padded_idx}@${x}x${y}_${tile_width}x${tile_height}_${frame_rate}"

    ffmpeg -f rawvideo \
      -video_size "${width}x${height}" \
      -pixel_format yuv420p \
      -i "$INPUT" \
      -filter:v "crop=${tile_width}:${tile_height}:${x}:${y}" \
      -y "${tile_path}.yuv"

    echo "${tile_width}  ${tile_height}  ${x}  ${y}  ${tile_path}.266" >> $output_path/subpicture.cfg
    echo "${tile_width}  ${tile_height}  ${x}  ${y}  $tile_idx.266" >> $output_path/subpicture_idx.cfg

  done
done
