#import cv2
 
def overlap(r1,r2):

    r1xcenter = (r1['right']-r2['left'])/2 + r2['left']
    r1ycenter = (r1['bottom']-r2['top'])/2 + r2['top']

    hoverlaps = r2['right'] >= r1xcenter >= r2['left']
    voverlaps = r2['bottom'] >= r1ycenter >= r2['top']

    return hoverlaps and voverlaps

# end function overlap

def numOfFaces(filename, cv2):
    
    image = cv2.imread(filename)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    detector = cv2.CascadeClassifier("images/haarcascade_frontalface_default.xml")
    detector2 = cv2.CascadeClassifier("images/haarcascade_profileface.xml")

    faces = []
    rects = detector.detectMultiScale(gray, scaleFactor=1.3,
    	minNeighbors=10, minSize=(15, 15))
    
    for (i, (x, y, w, h)) in enumerate(rects): faces.append(image[y:y+h, x:x+w])

    rects2 = detector2.detectMultiScale(gray, scaleFactor=1.3,
    	minNeighbors=10, minSize=(15, 15))

    rects3 = []		
    dontoverlap = True
    for (i, (xi, yi, wi, hi)) in enumerate(rects2):
    	dontoverlap == True
    	for (j, (xj, yj, wj, hj)) in enumerate(rects):
    		dontoverlap = not overlap({'left':xi, 'top':yi, 'right':xi+wi, 'bottom':yi+hi}, 
    		{'left':xj, 'top':yj, 'right':xj+wj, 'bottom':yj+hj})
    	if 	dontoverlap == True: 
    		rects3.append(rects2[i])
    
    for (i, (x, y, w, h)) in enumerate(rects3): faces.append(image[y:y+h, x:x+w])

    return faces

# end function numOfFaces
		
