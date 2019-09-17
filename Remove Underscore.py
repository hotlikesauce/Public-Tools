import os
root =("[YOUR PATH]")
for path, folders, files in os.walk(root):
    print folders
    for f in files:
        os.rename(os.path.join(path, f), os.path.join(path, f.replace('_', '')))
