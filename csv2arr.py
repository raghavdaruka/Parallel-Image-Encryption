import numpy as np
import cv2
import csv
from PIL import Image

img=cv2.imread('/home/raghav/Documents/PcapProject/classify.jpg',cv2.IMREAD_GRAYSCALE)
cv2.namedWindow('image', cv2.WINDOW_NORMAL)
cv2.imshow('image',img)
k = cv2.waitKey(0) & 0xFF
if k == 27:         # wait for ESC key to exit
    cv2.destroyAllWindows()
elif k == ord('s'): # wait for 's' key to save and exit
    cv2.imwrite('/home/raghav/Documents/PcapProject/classify.jpg',img)
    cv2.destroyAllWindows()
mat=np.array(img).astype(float)
print(mat.shape)
print("Matrix\n")
print(mat)
np.savetxt("/home/raghav/Documents/PcapProject/mat.csv",mat,fmt='%f',delimiter=",")

