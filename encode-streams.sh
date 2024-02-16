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
STREAM_A=HQ_Long_IRAP
STREAM_C=LQ_Long_IRAP
STREAM_B=HQ_Short_IRAP
STREAM_D=LQ_Short_IRAP

exec $ENCODER \
    --TreatAsSubPic 1 \
    --IntraPeriod 128 \
    --DecodingRefreshType 2 \
    --GOPSize 32 \
    --QP 16 \
    --Size "$width"x"$height" \
    --FrameRate "$framerate" \
    --FramesToBeEncoded $FRAMES_TO_BE_ENCODED \
    --InputFile "$FILENAME" \
    --BitstreamFile "$OUT_PATH/$STREAM_A\\_$BASENAME.266" \
    &> "$LOG_PATH/$STREAM_A.encoder.log" & exec $ENCODER \
    --TreatAsSubPic 1 \
    --IntraPeriod 128 \
    --DecodingRefreshType 2 \
    --GOPSize 32 \
    --QP 49 \
    --Size "$width"x"$height" \
    --FrameRate "$framerate" \
    --FramesToBeEncoded $FRAMES_TO_BE_ENCODED \
    --InputFile "$FILENAME" \
    --BitstreamFile "$OUT_PATH/$STREAM_C\\_$BASENAME.266" \
    &> "$LOG_PATH/$STREAM_C.encoder.log" & exec $ENCODER \
    --TreatAsSubPic 1 \
    --IntraPeriod 32 \
    --DecodingRefreshType 2 \
    --GOPSize 16 \
    --QP 16 \
    --Size "$width"x"$height" \
    --FrameRate "$framerate" \
    --FramesToBeEncoded $FRAMES_TO_BE_ENCODED \
    --InputFile "$FILENAME" \
    --BitstreamFile "$OUT_PATH/$STREAM_B\\_$BASENAME.266" \
    &> "$LOG_PATH/$STREAM_B.encoder.log" & exec $ENCODER \
    --TreatAsSubPic 1 \
    --IntraPeriod 128 \
    --DecodingRefreshType 2 \
    --GOPSize 32 \
    --QP 49 \
    --Size "$width"x"$height" \
    --FrameRate "$framerate" \
    --FramesToBeEncoded $FRAMES_TO_BE_ENCODED \
    --InputFile "$FILENAME" \
    --BitstreamFile "$OUT_PATH/$STREAM_D\\_$BASENAME.266" \
    &> "$LOG_PATH/$STREAM_D.encoder.log"
