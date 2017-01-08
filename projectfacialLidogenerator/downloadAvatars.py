from shutil import copyfile
import pandas as pd
import datetime
from getpass import getpass
import os
import time
import sys

try:
    import requests
except ImportError:
    print("Cannot find 'requests' module. Please install it and try again.")
    sys.exit(0)

try:
    from vk_api import VkApi
except ImportError:
    print("Cannot find 'vk_api' module. Please install it and try again.")
    sys.exit(0)

def downloadAvas(srcDownloadPrefix, dstPrefix, facesSrc, filePrefix, hmf, cv2, num):
    '''
    srcDownloadPrefix, - where to download photos 
    dstPrefix, - where to copy if 1 face found
    facesSrc, - list of account ids
    filePrefix, - prefix to mark downloaded file with to define good from bad
    hmf, - a script for how many faces
    cv2, - comp vision module
    num - how many profiles should we take from an src file
    
    1 download file
    2 check num of faces
    3 if 1 face => copy to dst folder
    4 timeout passed 'cause long face recognition, so vk won't block session
    '''

    df = pd.read_csv(facesSrc)
    accountIDs = df['col2']

    login = "RvsdL@bk.ru"
    password = "SargeVKONTAKTE"
    connection = VkApi(login, password)

    start_time = datetime.datetime.now()
    counter = 0
    for i in enumerate(accountIDs):
#         if counter <= 355 and filePrefix == "b": 
#             counter += 1
#             continue
        print "{}: line {}, of {}".format(datetime.datetime.now(), counter, num)
        filename = str(accountIDs[counter])

        src = srcDownloadPrefix + filePrefix + filename + ".jpg"
        dst = dstPrefix + filePrefix + filename + ".jpg"

        #download file with src filename
        #https://vk.com/dev/users.get?params[user_ids]=100100628&params[fields]=photo_max_orig&params[name_case]=Nom&params[v]=5.60
        avatar = connection.method('users.get', {'user_ids': filename,'fields': 'photo_max_orig'})
        url = avatar[0].get('photo_max_orig')
#         if counter > 355 and filePrefix == "b": print(url)
        output = srcDownloadPrefix
        r = requests.get(url)
        title = filePrefix + filename

        with open(os.path.join(output, '%s.jpg' % title), 'wb') as f:
            for buf in r.iter_content(1024):
                if buf:
                    f.write(buf)

        if r.status_code > 200: 
            print(url)
        else: 
            faces = hmf.numOfFaces(src, cv2)
            if len(faces) == 1: 
                cv2.imwrite(dst, faces[0])
            #copyfile(src, dst)    
              
   
        counter = counter + 1
        if counter >= num: break

    end_time = datetime.datetime.now()

    print "started {}, ended {}".format(start_time, end_time)
    print("Done in %s" % (datetime.datetime.now() - start_time))