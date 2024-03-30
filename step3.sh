WORKING_DIRECTORY="$1"

cp "$WORKING_DIRECTORY/tiles/subpicture_idx.cfg" "$WORKING_DIRECTORY/presentation/subpicture.cfg"

# Merge the tiles
cd $WORKING_DIRECTORY/presentation
~/Documents/VVCSoftware_VTM/bin/SubpicMergeAppStatic -m 1 -l subpicture.cfg -o out.266

# Calculate PSNR
printf '%s\n' *.log > logs_path.txt
python ../../psnr-from-logs.py -l logs_path.txt

cd ../../
