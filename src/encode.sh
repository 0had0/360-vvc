#!/bin/bash

# Set the default directory to './tiles'
directory=${1:-./tiles}
# Set the cfg argument, no default value is provided, so it's optional
cfg=${2:-./cfg/fixed-gop-length.cfg}

# Check if the directory exists
if [ ! -d "$directory" ]; then
    echo "Directory does not exist: $directory"
    exit 1
fi

echo "$cfg"

exec &> encoding.log


# Loop over all .yuv files in the given directory
for file in "$directory"/*.yuv; do
    # Check if no .yuv files are found
    if [ "$file" == "$directory/*.yuv" ]; then
        echo "No .yuv files found in $directory."
        break
    fi

    # Get the file path without the extension
    filepath_without_extension="${file%.yuv}"

    # Extract the parameters from the filename
    filename="${file##*/}"
    base="${filename%.yuv}"
    IFS='_' read -r -a params <<< "$base"
    tile_width="${params[1]}"
    tile_height="${params[2]}"
    # x="${params[3]}"
    # y="${params[4]}"

    ../bin/vvencFFapp -c "$cfg" \
                 --TreatAsSubPic --ALF 0 \
                 --Size "${tile_width}x${tile_height}" \
                 --InputFile "$file" \
                 --FrameRate 30 \
                 --BitstreamFile "${filepath_without_extension}.266"

done
