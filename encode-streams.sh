#!/bin/bash

if [ "$#" -ne 3 ]; then
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

OUT_PATH="$2"
LOG_PATH="$3"

echo "Processing file: $BASENAME"
echo "Width: $width, Height: $height, FrameRate: $framerate"

# Encode 4 bitstreams:
HQ_Long_IRAP=HQ_Long_IRAP
LQ_Long_IRAP=LQ_Long_IRAP
HQ_Short_IRAP=HQ_Short_IRAP
LQ_Short_IRAP=LQ_Short_IRAP

size="$width"x"$height"
DEFAULT="--TreatAsSubPic 1 --NoTID --ForceMvdL1 --STA 0 --ALF 0 --Size $size --FrameRate $framerate --InputFile $FILENAME --DecodingRefreshType 2 --Level 6.1"
LONG_IRAP="--IntraPeriod 128 --GOPSize 32"
SHORT_IRAP="--IntraPeriod 32 --GOPSize 32"

# --FramesToBeEncoded $FRAMES_TO_BE_ENCODED \
# exec $ENCODER $DEFAULT $LONG_IRAP --QP 16 --BitstreamFile "$OUT_PATH/$HQ_Long_IRAP@$BASENAME.266" &> "$LOG_PATH/$HQ_Long_IRAP@$BASENAME.log" &
# exec $ENCODER $DEFAULT $LONG_IRAP --QP 50 --BitstreamFile "$OUT_PATH/$LQ_Long_IRAP@$BASENAME.266" &> "$LOG_PATH/$LQ_Long_IRAP@$BASENAME.log" &
# exec $ENCODER $DEFAULT $SHORT_IRAP --QP 16 --BitstreamFile "$OUT_PATH/$HQ_Short_IRAP@$BASENAME.266" &> "$LOG_PATH/$HQ_Short_IRAP@$BASENAME.log" &
# exec $ENCODER $DEFAULT $SHORT_IRAP --QP 50 --BitstreamFile "$OUT_PATH/$LQ_Short_IRAP@$BASENAME.266" &> "$LOG_PATH/$LQ_Short_IRAP@$BASENAME.log"
exec $ENCODER $DEFAULT $LONG_IRAP --QP 16 --BitstreamFile "$OUT_PATH/$HQ_Long_IRAP.266" &> "$LOG_PATH/$HQ_Long_IRAP.log" &
exec $ENCODER $DEFAULT $LONG_IRAP --QP 50 --BitstreamFile "$OUT_PATH/$LQ_Long_IRAP.266" &> "$LOG_PATH/$LQ_Long_IRAP.log" &
exec $ENCODER $DEFAULT $SHORT_IRAP --QP 16 --BitstreamFile "$OUT_PATH/$HQ_Short_IRAP.266" &> "$LOG_PATH/$HQ_Short_IRAP.log" &
exec $ENCODER $DEFAULT $SHORT_IRAP --QP 50 --BitstreamFile "$OUT_PATH/$LQ_Short_IRAP.266" &> "$LOG_PATH/$LQ_Short_IRAP.log"
