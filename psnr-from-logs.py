import sys, os

import numpy as np

from parse_logs import extract_metrics


def read_paths(file_path):
    paths = []
    with open(file_path, "r") as file:
        for line in file:
            log_file_path = line.strip()
            if os.path.exists(log_file_path):
                paths.append(log_file_path)
            else:
                print(f"Warning: Log file not found: {log_file_path}")

    return paths


def group_by_poc(metrics_objects):
    """
    Group poc object together
    """
    grouped_objects = {}
    for metric_object in metrics_objects:
        for elm in metric_object:
            poc = elm["POC"]
            if poc not in grouped_objects:
                grouped_objects[poc] = []
            grouped_objects[poc].append(elm)

    return grouped_objects


def mse_from_metrics(metric_object, max_pixel):
    mse = {}

    for component in ["Y", "U", "V"]:
        if metric_object[f"{component}-PSNR"] != float("inf"):
            mse[component] = 10 ** (
                2 * np.log10(max_pixel) - (metric_object[f"{component}-PSNR"]) / 10
            )
        else:
            mse[component] = float("inf")

    return mse


def avg(arr):
    y, u, v, Bits, count = 0, 0, 0, 0, 0
    for metrics in arr:
        y += metrics["Y"]
        u += metrics["U"]
        v += metrics["V"]
        Bits += metrics["Bits"]
        count += 1

    return {"Y": y / count, "U": u / count, "V": v / count, "Bits": Bits / count}


def psnr_from_mse(metrics, bit_depth):
    max_pixel = 2**bit_depth

    mse_per_poc = [
        avg(
            [
                mse_from_metrics(subpicture_metrics, max_pixel)
                for subpicture_metrics in subpictures_metrics
            ]
        )
        for subpictures_metrics in list(group_by_poc(metrics).values())
    ]

    return {
        component: np.mean(
            [10 * np.log10(max_pixel * 2 / mse.get(component)) for mse in mse_per_poc]
        )
        for component in ["Y", "U", "V"]
    }


def psnr(metrics):
    return {
        component: np.mean(
            [
                _psnr.get(component)
                for _psnr in [
                    avg(
                        [
                            {
                                component: subpicture_metrics[
                                    (
                                        f"{component}-PSNR"
                                        if component is not "Bits"
                                        else component
                                    )
                                ]
                                for component in ["Y", "U", "V", "Bits"]
                            }
                            for subpicture_metrics in subpictures_metrics
                        ]
                    )
                    for subpictures_metrics in list(group_by_poc(metrics).values())
                ]
            ]
        )
        for component in ["Y", "U", "V", "Bits"]
    }


if __name__ == "__main__":
    if len(sys.argv) < 3 or len(sys.argv) > 5 or sys.argv[1] != "-l":
        print("Usage: python script.py -l <file_path.txt> [-d <int_value>]")
        sys.exit(1)

    file_path = sys.argv[2]
    pixel_depth = int(sys.argv[4]) if len(sys.argv) == 5 else None

    log_paths = read_paths(file_path)
    metrics = [extract_metrics(path) for path in log_paths]

    # print(file_path, len(metrics))
    for index, path in enumerate(log_paths):
        print(path, len(metrics[index]))

    print(f"[PSNR] {psnr(metrics)}")
