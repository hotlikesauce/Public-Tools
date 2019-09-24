import arcpy

arcpy.env.workspace = "[Your Path Here]"
for fc in arcpy.ListFeatureClasses():
	arcpy.Delete_management("Database Connections//devTest_Replica.sde//"+str(fc))
	print "Deleted: " + str(fc)
