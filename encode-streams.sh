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

echo "Processing file: $BASENAME"
echo "Width: $width, Height: $height, FrameRate: $framerate"

# Encode 4 bitstreams:
HQ_Long_IRAP=HQ_Long_IRAP
LQ_Long_IRAP=LQ_Long_IRAP
HQ_Short_IRAP=HQ_Short_IRAP
LQ_Short_IRAP=LQ_Short_IRAP

# --FramesToBeEncoded $FRAMES_TO_BE_ENCODED \
exec $ENCODER \
    --TreatAsSubPic 1 \
    --IntraPeriod 128 \
    --DecodingRefreshType 2 \
    --GOPSize 32 \
    --QP 16 \
    --Size "$width"x"$height" \
    --FrameRate "$framerate" \
    --InputFile "$FILENAME" \
    --BitstreamFile "$OUT_PATH/$HQ_Long_IRAP@$BASENAME.266" \
    &> "$LOG_PATH/$HQ_Long_IRAP.encoder.log" & exec $ENCODER \
    --TreatAsSubPic 1 \
    --IntraPeriod 128 \
    --DecodingRefreshType 2 \
    --GOPSize 32 \
    --QP 49 \
    --Size "$width"x"$height" \
    --FrameRate "$framerate" \
    --InputFile "$FILENAME" \
    --BitstreamFile "$OUT_PATH/$LQ_Long_IRAP@$BASENAME.266" \
    &> "$LOG_PATH/$LQ_Long_IRAP.encoder.log" & exec $ENCODER \
    --TreatAsSubPic 1 \
    --IntraPeriod 32 \
    --DecodingRefreshType 2 \
    --GOPSize 16 \
    --QP 16 \
    --Size "$width"x"$height" \
    --FrameRate "$framerate" \
    --InputFile "$FILENAME" \
    --BitstreamFile "$OUT_PATH/$HQ_Short_IRAP@$BASENAME.266" \
    &> "$LOG_PATH/$HQ_Short_IRAP.encoder.log" & exec $ENCODER \
    --TreatAsSubPic 1 \
    --IntraPeriod 32 \
    --DecodingRefreshType 2 \
    --GOPSize 16 \
    --QP 49 \
    --Size "$width"x"$height" \
    --FrameRate "$framerate" \
    --InputFile "$FILENAME" \
    --BitstreamFile "$OUT_PATH/$LQ_Short_IRAP@$BASENAME.266" \
    &> "$LOG_PATH/$LQ_Short_IRAP.encoder.log"
