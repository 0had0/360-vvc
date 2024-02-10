# Experiment 3:
#   - Why? Switch from stream B (short length GOP with higher QP), on second IDR, to stream A (long length GOP)
#   - Preconditions: switch point should be aligned, CRA frame from stream A (long length GOP) should be the IDR frame of stream B (short length GOP with higher QP)

# Encode Stream A (using long length GOP)

# Encode Stream D (using short length GOP with higher QP)

# Create stream A container

# Create stream D container

# Manually edit stream A nhml file, delete all NAL Samples before the first CRA

# Manually edit stream D nhml file, delete all NAL Samples after the second IDR

# Create a playlist stream F (B (till the first IDR) -> D (from the second CRA) -> D (again just for fun))

# play the playlist
