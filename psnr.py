import os, sys, csv

import cv2
import numpy as np


def process_text_file(file_path):
  original_paths, decoded_paths = [], []

  with open(file_path, 'r') as file:
      reader = csv.reader(file, delimiter=' ')
      for row in reader:
          if len(row) != 2:
              raise ValueError(f"Invalid line format in {file_path}: Expected two columns")

          original_path, decoded_path = row

          if not os.path.exists(original_path):
              print(f"Warning: Original file not found: {original_path}")
          if not os.path.exists(decoded_path):
              print(f"Warning: Decoded file not found: {decoded_path}")

          original_paths.append(original_path)
          decoded_paths.append(decoded_path)

  return original_paths, decoded_paths


def mse(original, denoised):
  original = original.astype(np.float32)
  denoised = denoised.astype(np.float32)

  return np.mean((original - denoised) ** 2)

vectorized_mse = np.vectorize(mse)


def frame_psnr(original_subpictures, decoded_subpictures, max_pixel):

  return 10 * np.log10(
     max_pixel / np.mean(
        vectorized_mse(
            zip(original_subpictures, decoded_subpictures)
    )))

def psnr(original_subvideo_paths, decoded_subvideo_paths, pixel_depth):
  max_pixel = 2 ** pixel_depth
    
  original_subvideo_caps = [cv2.VideoCapture(path) for path in original_subvideo_paths]
  decoded_subvideo_caps = [cv2.VideoCapture(path) for path in decoded_subvideo_paths]

  assert len(original_subvideo_caps) == len(decoded_subvideo_caps), "paths are not equal"

  if not np.all([x.isOpened() for x in [*original_subvideo_caps, *decoded_subvideo_caps]]):
      print("Error opening video stream or file")
      return
  
  psnrs = []

  while True:
      original_rets, original_subpictures = [x.read() for x in original_subvideo_caps]
      decoded_rets, decoded_subpictures = [x.read() for x in decoded_subvideo_caps]

      if not np.all(original_rets) or not np.all(decoded_rets):
          break
      
      psnrs.append(
       frame_psnr(
          original_subpictures,
          decoded_subpictures,
          max_pixel
       ))

  return np.mean(psnrs)


if __name__ == '__main__':
   if len(sys.argv) != 5 or sys.argv[1] != "-l" or sys.argv[3] != "-d":
     print("Usage: python script.py -l <file_path.txt> -d <int_value>")
     exit(1)

   file_path = sys.argv[2]
   pixel_depth = int(sys.argv[4])

   original_paths, decoded_paths = process_text_file(file_path)

   print(f"[PSNR: {psnr(*process_text_file(file_path), pixel_depth)}]")
