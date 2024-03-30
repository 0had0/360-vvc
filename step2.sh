WORKING_DIRECTORY="$1"
PRESENTATION_LIST_PATH="$2"
TRANSITION_POC="$3"

# Create Presentation Directory
PRESENTATION_PATH=$WORKING_DIRECTORY/presentation
mkdir -p $PRESENTATION_PATH
rm -rf $PRESENTATION_PATH
mkdir $PRESENTATION_PATH

ENCODER_OUTPUT_PATH=$WORKING_DIRECTORY/encoder_output
HQ_Long_IRAP=HQ_Long_IRAP
LQ_Long_IRAP=LQ_Long_IRAP
HQ_Short_IRAP=HQ_Short_IRAP
LQ_Short_IRAP=LQ_Short_IRAP

process_transation_log() {
  touch $1/concat.log
  while IFS=" " read -r file_path start_line end_line; do
    
    # Extract lines before, target content, and after
    sed -n "$start_line,$((end_line))p;$((end_line + 1))q" "$file_path" >> $1/concat.log

  done < "$1/transition.log"
}

tile_idx=0
count=0
# Read the Presentation list
while IFS= read -r value; do
  tile_idx=$((++count))
  echo "[Processing tile: $tile_idx]: found value $value"

  if [[ $value == 0 ]]; then
    # Hidden Subpicture
    cp $ENCODER_OUTPUT_PATH/$tile_idx/$LQ_Long_IRAP.266 $PRESENTATION_PATH/$tile_idx.266
    cp $ENCODER_OUTPUT_PATH/$tile_idx/$LQ_Long_IRAP.log $PRESENTATION_PATH/$tile_idx.log
  elif [[ $value == 1 ]]; then
    # Transition from Low to High on given POC
    mkdir $PRESENTATION_PATH/tmp

    # Copy streams required for merge
    cp $ENCODER_OUTPUT_PATH/$tile_idx/$LQ_Long_IRAP.266 $PRESENTATION_PATH/tmp/
    cp $ENCODER_OUTPUT_PATH/$tile_idx/$LQ_Long_IRAP.log $PRESENTATION_PATH/tmp/

    cp $ENCODER_OUTPUT_PATH/$tile_idx/$HQ_Short_IRAP.266 $PRESENTATION_PATH/tmp/
    cp $ENCODER_OUTPUT_PATH/$tile_idx/$HQ_Short_IRAP.log $PRESENTATION_PATH/tmp/

    cp $ENCODER_OUTPUT_PATH/$tile_idx/$HQ_Long_IRAP.266 $PRESENTATION_PATH/tmp/
    cp $ENCODER_OUTPUT_PATH/$tile_idx/$HQ_Long_IRAP.log $PRESENTATION_PATH/tmp/

    # Generate a Playlist of the Transtion, along with a transition.log file
    ./generate-nhml.sh $PRESENTATION_PATH/tmp
    ./generate_transition.sh $TRANSITION_POC 1 $PRESENTATION_PATH/tmp

    # Output the stream and the logs
    ~/Documents/gpac/bin/gcc/gpac -i $PRESENTATION_PATH/tmp/playlist.txt -o $PRESENTATION_PATH/$tile_idx.266
    process_transation_log $PRESENTATION_PATH/tmp
    mv $PRESENTATION_PATH/tmp/concat.log $PRESENTATION_PATH/$tile_idx.log

    # Clean
    rm -rf $PRESENTATION_PATH/tmp
  elif [[ $value == 2 ]]; then
    # Transition from Low to High on given POC
    mkdir $PRESENTATION_PATH/tmp

    # Copy streams required for merge
    cp $ENCODER_OUTPUT_PATH/$tile_idx/$HQ_Long_IRAP.266 $PRESENTATION_PATH/tmp/
    cp $ENCODER_OUTPUT_PATH/$tile_idx/$HQ_Long_IRAP.log $PRESENTATION_PATH/tmp/

    cp $ENCODER_OUTPUT_PATH/$tile_idx/$LQ_Short_IRAP.266 $PRESENTATION_PATH/tmp/
    cp $ENCODER_OUTPUT_PATH/$tile_idx/$LQ_Short_IRAP.log $PRESENTATION_PATH/tmp/

    cp $ENCODER_OUTPUT_PATH/$tile_idx/$LQ_Long_IRAP.266 $PRESENTATION_PATH/tmp/
    cp $ENCODER_OUTPUT_PATH/$tile_idx/$LQ_Long_IRAP.log $PRESENTATION_PATH/tmp/

    # Generate a Playlist of the Transtion, along with a transition.log file
    ./generate-nhml.sh $PRESENTATION_PATH/tmp
    ./generate_transition.sh $TRANSITION_POC 2 $PRESENTATION_PATH/tmp

    # Output the stream and the logs
    ~/Documents/gpac/bin/gcc/gpac -i $PRESENTATION_PATH/tmp/playlist.txt -o $PRESENTATION_PATH/$tile_idx.266
    process_transation_log $PRESENTATION_PATH/tmp
    mv $PRESENTATION_PATH/tmp/concat.log $PRESENTATION_PATH/$tile_idx.log

    # Clean
    rm -rf $PRESENTATION_PATH/tmp
  elif [[ $value == 3 ]]; then
    # Shown Subpicture
    cp $ENCODER_OUTPUT_PATH/$tile_idx/$HQ_Long_IRAP.266 $PRESENTATION_PATH/$tile_idx.266
    cp $ENCODER_OUTPUT_PATH/$tile_idx/$HQ_Long_IRAP.log $PRESENTATION_PATH/$tile_idx.log
  elif [[ $value == 4 ]]; then
    # Hidden Subpicture
    cp $ENCODER_OUTPUT_PATH/$tile_idx/$LQ_Short_IRAP.266 $PRESENTATION_PATH/$tile_idx.266
    cp $ENCODER_OUTPUT_PATH/$tile_idx/$LQ_Short_IRAP.log $PRESENTATION_PATH/$tile_idx.log
  elif [[ $value == 5 ]]; then
    # Shown Subpicture
    cp $ENCODER_OUTPUT_PATH/$tile_idx/$HQ_Short_IRAP.266 $PRESENTATION_PATH/$tile_idx.266
    cp $ENCODER_OUTPUT_PATH/$tile_idx/$HQ_Short_IRAP.log $PRESENTATION_PATH/$tile_idx.log
  fi

done < $PRESENTATION_LIST_PATH
