# import the necessary packages
import argparse
import cv2
 
# construct the argument parse and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-i", "--image", required=True,
	help="path to the input image")
ap.add_argument("-c", "--cascade",
	default="images/haarcascade_frontalface_default.xml",
	help="path to cat detector haar cascade")
args = vars(ap.parse_args())

# load the input image and convert it to grayscale
image = cv2.imread(args["image"])
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
#cv2.imshow("Original", gray)
 
def overlap(r1,r2):
    r1xcenter = (r1['right']-r2['left'])/2 + r2['left']
    r1ycenter = (r1['bottom']-r2['top'])/2 + r2['top']
    hoverlaps = r2['right'] >= r1xcenter >= r2['left']
    voverlaps = r2['bottom'] >= r1ycenter >= r2['top']
    return hoverlaps and voverlaps
     
# load the cat detector Haar cascade, then detect cat faces
# in the input image
detector = cv2.CascadeClassifier(args["cascade"])
detector2 = cv2.CascadeClassifier("images/haarcascade_profileface.xml")
try:
    rects = detector.detectMultiScale(gray, scaleFactor=1.3,
    	minNeighbors=10, minSize=(15, 15))
except downloadError: 
    print('error')

try:
    rects2 = detector2.detectMultiScale(gray, scaleFactor=1.3,
    	minNeighbors=10, minSize=(15, 15))
except downloadError: 
    print('error')
	
faces = []
for (i, (x, y, w, h)) in enumerate(rects):
	cv2.rectangle(image, (x, y), (x + w, y + h), (0, 0, 255), 2)
	cv2.putText(image, "face #{}".format(i + 1), (x, y - 10),
		cv2.FONT_HERSHEY_SIMPLEX, 0.55, (0, 0, 255), 2)
	roi = image[y:y+h, x:x+w]
	faces.append(roi)

rects3 = []		
dontoverlap = True
for (i, (xi, yi, wi, hi)) in enumerate(rects2):
    dontoverlap == True
    for (j, (xj, yj, wj, hj)) in enumerate(rects):
        dontoverlap = not overlap({'left':xi, 'top':yi, 'right':xi+wi, 'bottom':yi+hi}, 
        {'left':xj, 'top':yj, 'right':xj+wj, 'bottom':yj+hj})
    if 	dontoverlap == True: 
        rects3.append(rects2[i])
        

for (i, (x, y, w, h)) in enumerate(rects3):
	cv2.rectangle(image, (x, y), (x + w, y + h), (0, 0, 255), 2)
	cv2.putText(image, "face #{}".format(i + 1), (x, y - 10),
		cv2.FONT_HERSHEY_SIMPLEX, 0.55, (0, 0, 255), 2)
	roi = image[y:y+h, x:x+w]
	faces.append(roi)
		
# print "Found {0} faces!".format(len(rects)) 
# print "Found {0} faces!".format(len(rects3)) 
# show the detected faces
#cv2.imshow("detected faces", image)

#for i in faces: cv2.imshow("face",i)
print 'found faces: {0}'.format(len(faces))
if len(faces) == 1: 
    cv2.imshow("face", faces[0])
cv2.waitKey(0)