import numpy as np
import cv2
import csv
from PIL import Image

reader = csv.reader(open("/home/raghav/Documents/PcapProject/ReceivedMat.csv", "r"), delimiter=",")
x = list(reader)
print(type(x))
print(x)
result = np.array(x).astype("float")
im = Image.fromarray(result)
im.show()