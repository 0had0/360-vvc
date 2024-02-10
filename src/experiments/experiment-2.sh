# Experiment 2:
#   - Why? Switch from stream A (long length GOP), on insered CRA, to stream B (short length GOP with higher QP)
#   - Preconditions: switch point should be aligned, CRA frame from stream A (long length GOP) should be the IDR frame of stream B (short length GOP with higher QP)

# Encode Stream A (using long length GOP)

# Encode Stream D (using short length GOP with higher QP)

# Create stream A container

# Create stream D container

# Manually edit stream A nhml file, delete all NAL Samples after the first CRA

# Manually edit stream D nhml file, delete all NAL Samples before the second IDR

# Create a playlist stream E (A (till the first CRA) -> D (from the second IDR) -> D (again just for fun))

# play the playlist
