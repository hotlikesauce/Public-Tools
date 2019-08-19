import arcpy

arcpy.env.workspace = ("[YOUR PATH]")
array = arcpy.ListFeatureClasses()

#print array

for fc in array:
    try:
        arcpy.AddGlobalIDs_management(fc)
        #arcpy.RegisterAsVersioned_management(fc, "NO_EDITS_TO_BASE")
        print fc + " --- Added Global IDs"
    except Exception, err:
        print "(##FAIL##) " + fc + " --- Existing Global IDs"
        print err
        pass

       
