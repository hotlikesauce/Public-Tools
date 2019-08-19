import arcpy

arcpy.env.workspace = "Database Connections//devTest_Replica.sde"
for fc in arcpy.ListFeatureClasses():
	arcpy.Delete_management("Database Connections//devTest_Replica.sde//"+str(fc))
	print "Deleted: " + str(fc)
