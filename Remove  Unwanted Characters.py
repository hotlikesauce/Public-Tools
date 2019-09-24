##This script will remove unwanted characters from a file name
##I have it set up to remove underscores but change the underscore text in the last line to make it whatever you want

import os
root =("[YOUR PATH]")
for path, folders, files in os.walk(root):
    print folders
    for f in files:
        os.rename(os.path.join(path, f), os.path.join(path, f.replace('_', '')))
