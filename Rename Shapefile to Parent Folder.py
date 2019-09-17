#This tool is useful whenever you get some rough data deliverables
#I used this whenever I had ~100 individually names folders, all containing a single shapefile with the same name, "Data.shp"
#The goal was to rename the shapes from Data.shp, to the parent folder's name.shp


import os, arcpy
from subprocess import Popen
import subprocess
from os import listdir
from os.path import isfile, join



myDir = ("Path to Folder, containing all of the sub folders")
shpList = []
csvList = []
newshpList = []

for root, dirs, files in os.walk(myDir):
    for file in files:
        if file.endswith(".shp"):
            shpList.append(os.path.join(root, file))
         
for rawShapefile in shpList:
    folderName = str(os.path.basename(os.path.dirname(rawShapefile)))
    renameShapefile = str(myDir)+"\\"+folderName+"\\"+folderName+".shp"
    print(renameShapefile)
    arcpy.Rename_management(rawShapefile,renameShapefile)
