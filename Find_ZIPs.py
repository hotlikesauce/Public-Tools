import os
import arcpy
import zipfile
import shutil


path = "[YOUR PATH]"
folderArray = []
for dirname, dirnames, filenames in os.walk(path):
    # print path to all subdirectories first.
    for subdirname in dirnames:
        folderArray.append(os.path.join(dirname, subdirname))
        print subdirname
    for file in filenames:
        path_file = os.path.join(dirname,file)
        shutil.copy2(path_file,'[PATH]') # change you destination dir
            


##for folder in folderArray:
##    arcpy.env.workspace = folder
##    arcpy.ListFeatureClasses()
##    time.sleep(3)
