import qrcode, os, subprocess
from subprocess import Popen

##Array of Links, websites, etc
##I used this to create QR codes of KMZ Files so users can access via Avenza Maps
s3URLs = ['google.com','yahoo.com','espn.com']


for URL in s3URLs:
    ##Format File Name and remoce .com, .kmz whatever, with .png
    fileName = (str(URL.replace("https://s3-us-west-2.amazonaws.com/personal-tward/France","")))[:-4]
    #Open cmd Line to gen qr code
    newCMD = ('qr ' + str(URL) + ' > ' + '"'+ "C://Users//tward//Documents//France/"+fileName+".png"+'"')
    print newCMD
    process = subprocess.Popen('cmd /k ' + newCMD)
    ##Close command window
    os.popen('TASKKILL /PID '+str(process.pid)+' /F')
