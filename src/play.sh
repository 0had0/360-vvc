dimensions=$(head -n 1 "$1" | egrep -o '[0-9]+x[0-9]+')
echo $dimensions
ffplay -f rawvideo -video_size "$dimensions" -pixel_format yuv420p10le "$2"
