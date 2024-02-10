#!/bin/bash

n=3
m=3
width=1920
height=1080
output_dir="tiles"

while getopts ":d:r:o:" opt; do
  case $opt in
    d) IFS='x' read -ra dims <<< "$OPTARG"
       n=${dims[0]}
       m=${dims[1]} ;;
    r) IFS='x' read -ra dims <<< "$OPTARG"
       width=${dims[0]}
       height=${dims[1]} ;;
    o) output_dir = "$OPTARG" ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND-1))

input_video=$1

if [ -z "$input_video" ]; then
  echo "Usage: $0 -d <grid_dimensions> <input_video>"
  exit 1
fi

mkdir -p $output_dir
rm -rf $output_dir/*
mkdir -p $output_dir
echo $width, $height, $n, $m

tile_width=$((width / n))
tile_height=$((height / m))
tile_width=$((tile_width / 128 * 128))
tile_height=$((tile_height / 128 * 128))

rm subpicture.cfg
touch subpicture.cfg

tile_idx=0

for ((i=0; i<n; i++)); do
  for ((j=0; j<m; j++)); do
    x=$((i * tile_width))
    y=$((j * tile_height))
    
    echo $x, $y, $tile_width, $tile_height

    tile_path="$output_dir/tile_${tile_width}_${tile_height}_${x}_${y}"

    ffmpeg -f rawvideo \
      -video_size "${width}x${height}" \
      -pixel_format yuv420p \
      -i "$input_video" \
      -filter:v "crop=${tile_width}:${tile_height}:${x}:${y}" \
      -y "${tile_path}.yuv"

    echo "${tile_width}  ${tile_height}  ${x}  ${y}  ${tile_path}.266" >> subpicture.cfg

  done
done
