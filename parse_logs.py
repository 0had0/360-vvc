import sys, re

REGEX = r"POC\s+(?P<poc>\d+)\s+TId:\s+(?P<tid>\d+)\s+\(\s*(?P<frame_type>[a-zA-Z_]+),\s+(?P<frame_genre>[a-zA-Z-]+),\s+QP\s+(?P<qp>\d+)(,\s+TF\s+(?P<tf>\d+))*\)\s+(?P<bits>\d+)\s+bits\s\[Y\s+(?P<y_psnr>[\S.]+)\s+dB\s+U\s+(?P<u_psnr>[\S.]+)\s+dB\s+V\s+(?P<v_psnr>[\S.]+)\s+dB\]"


def extract_metrics(file_path):
    metrics = []

    with open(file_path, "r") as file:
        lines = file.readlines()

    regex = re.compile(REGEX)

    for match in regex.finditer("".join(lines)):
        metric_dict = {
            "POC": int(match.group("poc")),
            "TId": int(match.group("tid")),
            "Frame Type": match.group("frame_type"),
            "Frame Genre": match.group("frame_genre"),
            "QP": int(match.group("qp")),
            "TF": int(match.group("tf")) if match.group("tf") else None,
            "Bits": int(match.group("bits")),
            "Y-PSNR": (
                float(match.group("y_psnr")) if match.group("y_psnr") != "inf" else 0
            ),
            "U-PSNR": (
                float(match.group("u_psnr"))
                if match.group("u_psnr") != "inf"
                else 0  # float("inf")
            ),
            "V-PSNR": (
                float(match.group("v_psnr"))
                if match.group("v_psnr") != "inf"
                else 0  # float("inf")
            ),
        }
        metrics.append(metric_dict)

    return metrics


if __name__ == "__main__":
    file_path = sys.argv[1]
    metrics = extract_metrics(file_path)
