# Experiment 0:
#   - Why? Switch from stream A (long length GOP), to stream B (short length GOP)

# Encode Stream A (using long length GOP)

# Encode Stream B (using short length GOP)

# Create stream A container

# Create stream B container

# Manually edit stream A nhml file, delete all NAL Samples after the first IDR

# Manually edit stream B nhml file, delete all NAL Samples before the Nth IDR (Nth IDR is aligned with the first IDR of stream A)

# Create a playlist stream J (A (till the first IDR) -> B (from the Nth IDR) -> B (again just for fun))

# play the playlist
