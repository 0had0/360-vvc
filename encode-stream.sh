#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <filename_widthxheight_framerate.yuv>"
    exit 1
fi

FILENAME="$1"

BASENAME=$(basename "$FILENAME" .yuv)
IFS='_' read -r name dimensions framerate <<< "$BASENAME"
IFS='x' read -r width height <<< "$dimensions"

# Ensure the .env file exists and source it
ENV_FILE=".env"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "Error: .env file not found."
    exit 2
fi

echo "Processing file: $FILENAME"
echo "Width: $width, Height: $height, FrameRate: $framerate"

# Encode 2 bitstreams:
STREAM_A=longGOPstream
exec $ENCODER \
    --TreatAsSubPic 1 \
    --IntraPeriod 128 \
    --DecodingRefreshType 2 \
    --GOPSize 32 \
    --Size "$width"x"$height" \
    --FrameRate "$framerate" \
    --FramesToBeEncoded $FRAMES_TO_BE_ENCODED \
    --InputFile "$FILENAME" \
    --BitstreamFile "$OUT_PATH/$STREAM_A\_$FILENAME.266" \
    &> "$LOG_PATH/$STREAM_A.encoder.log"

STREAM_B=shortGOPstream
exec $ENCODER \
    --TreatAsSubPic 1 \
    --IntraPeriod 32 \
    --DecodingRefreshType 2 \
    --GOPSize 16 \
    --Size "$width"x"$height" \
    --FrameRate "$framerate" \
    --FramesToBeEncoded $FRAMES_TO_BE_ENCODED \
    --InputFile "$FILENAME" \
    --BitstreamFile "$OUT_PATH/$STREAM_B\_$FILENAME.266" \
    &> "$LOG_PATH/$STREAM_B.encoder.log"
