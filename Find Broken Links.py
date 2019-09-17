import arcpy, os
path = "S:\North_Rockies\Jonah\GIS\GIS_V2\\"
for root, dirs, files in os.walk(path):
    for fileName in files:
        basename, extension = os.path.splitext(fileName)
        if extension == ".mxd":
            fullPath = os.path.join(root, fileName)
            mxd = arcpy.mapping.MapDocument(fullPath)
            brknList = arcpy.mapping.ListBrokenDataSources(mxd)
            if brknList:
                print '\n'
                print "MXD: " + fileName
                print fullPath
            for brknItem in brknList:
                print "\t" + brknItem.name + " - " + brknItem.dataSource
