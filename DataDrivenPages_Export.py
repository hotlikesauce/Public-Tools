#http://desktop.arcgis.com/en/arcmap/10.3/analyze/arcpy-mapping/datadrivenpages-class.htm

import arcpy  

mxd = arcpy.mapping.MapDocument(r"ENTER FILE PATH TO MXD")
for pageNum in range(1, mxd.dataDrivenPages.pageCount + 1):
    mxd.dataDrivenPages.currentPageID = pageNum
    pageName = mxd.dataDrivenPages.pageRow.Name 
    print "Exporting page {0} of {1}".format(str(mxd.dataDrivenPages.currentPageID), str(mxd.dataDrivenPages.pageCount))
    arcpy.mapping.ExportToPDF(mxd, r"ENTER_FILE_PATH" + str(pageName) + ".pdf")
