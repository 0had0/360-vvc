INPUT=""
N=3
M=3
PRESENTATION_LIST_PATH=""
TRANSITION_POC=1

while getopts ":i:d:l:t:" opt; do
  case $opt in
    i) INPUT="$OPTARG" ;;
    d) IFS='x' read -ra dims <<< "$OPTARG"
       N=${dims[0]}
       M=${dims[1]} ;;
    l) PRESENTATION_LIST_PATH="$OPTARG" ;;
    t) TRANSITION_POC="$OPTARG" ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND-1))

BASENAME=$(basename "$INPUT" .yuv)
IFS='_' read -r name dimensions framerate <<< "$BASENAME"

# mkdir -p $name
# rm -rf $name

# # Create Working Directory
# mkdir $name

# ./step1.sh $INPUT $name $N $M
./step2.sh $name $PRESENTATION_LIST_PATH $TRANSITION_POC
./step3.sh $name