# Experiment 1:
#   - Why? Switch from stream A (long length GOP), on insered CRA, to stream B (short length GOP)
#   - Preconditions: switch point should be aligned, CRA frame from stream A (long length GOP) should be the IDR frame of stream B (short length GOP)

# Encode Stream A (using long length GOP)

# Encode Stream B (using short length GOP)

# Create stream A container

# Create stream B container

# Manually edit stream A nhml file, delete all NAL Samples after the first CRA

# Manually edit stream B nhml file, delete all NAL Samples before the second IDR

# Create a playlist stream C (A (till the first CRA) -> B (from the second IDR) -> B (again just for fun))

# play the playlist
