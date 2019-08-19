import arcpy

fc = 'C:\\Users\\tward\\Documents\\ArcGIS\\Default.gdb\\Line_Feature_Class' # line feature layer  
bearing_field = 'BEARING' # bearing field
sr = arcpy.Describe(fc).spatialReference # spatial reference of lines  
with arcpy.da.UpdateCursor(fc,['SHAPE@',bearing_field],spatial_reference=sr) as cursor: # create cursor  
   for row in cursor: # loop through lines  
       pt1 = arcpy.PointGeometry(row[0].firstPoint,sr) # first point geometry  
       pt2 = arcpy.PointGeometry(row[0].lastPoint,sr) # last point geometry  
       row[1] = pt1.angleAndDistanceTo(pt2)[0] # (angle, distance)[0] = angle  
       if row[1] < 0: # if you want all positive angles  
           row[1] += 360  
       cursor.updateRow(row) # write value
 
