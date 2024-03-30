#!/bin/bash

INPUT="$1"
WORKING_DIRECTORY="$2"
N="$3"
M="$4"


# Split Video into NxM tiles
TILES_PATH=$WORKING_DIRECTORY/tiles
mkdir $TILES_PATH

./tile.sh -i $INPUT -d ${M}x${N} -o $TILES_PATH

# Create Encoder Output Directory
ENCODER_OUTPUT_PATH="$WORKING_DIRECTORY/encoder_output"
mkdir $ENCODER_OUTPUT_PATH

count=0
TILE_IDX=0
# Encode 4 version of each tile
for file in $TILES_PATH/*; do
  filename=$(basename "$file" .yuv)
  IFS='_' read -r name dimensions framerate <<< "$filename"
  IFS='@' read -r idx res <<< "$name"
  IFS='x' read -r n m <<< "$res"

  TILE_IDX=$((++count))

  echo "Processing : $filename (tile # $TILE_IDX)"

  TILE_IDX_PATH="$ENCODER_OUTPUT_PATH/$TILE_IDX"
  
  mkdir $TILE_IDX_PATH
  
  ./encode-streams.sh $file $TILE_IDX_PATH $TILE_IDX_PATH
done
