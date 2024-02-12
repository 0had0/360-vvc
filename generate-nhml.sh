#!bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <bitstream.266>"
    exit 1
fi

BITSTREAM="$1"
NHML=$(echo "$BITSTREAM" | sed 's/\.266$/.nhml/')

$MP4BOX -add $BITSTREAM -new - | gpac -i - -o $OUT_PATH/$NHML:pckp