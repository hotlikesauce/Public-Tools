##This script will delete all FCs in a giver file path.
##This works for SDE Databases, as well as folder paths.

import arcpy

arcpy.env.workspace = "[Your Path Here]"
for fc in arcpy.ListFeatureClasses():
	arcpy.Delete_management("Database Connections//devTest_Replica.sde//"+str(fc))
	print "Deleted: " + str(fc)
