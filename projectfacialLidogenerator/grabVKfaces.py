import howManyFaces as hmf
import cv2
import downloadAvatars as da
#from shutil import copyfile
import argparse
 
# construct the argument parse and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-n", "--number", default = 50,
	help="num of avatars")
args = vars(ap.parse_args())

'''

1 download avatars from good and bad faces file to vkDownloadedAvatars 
  folder and with file prefix g or b to define later
2 go through faces, find 1 and only one face, then copy to good or bad folder respectfully of a file prefix

'''

srcDownloadPrefix = "vkDownloadedAvatars/"
dstGoodPrefix = "goodFaces/"
dstBadPrefix = "badFaces/"

da.downloadAvas(srcDownloadPrefix, dstGoodPrefix, "goodFaces.csv", "g", hmf, cv2, int(args['number']))
da.downloadAvas(srcDownloadPrefix, dstBadPrefix, "badFaces.csv", "b", hmf, cv2, int(args['number']))

print("ready")
