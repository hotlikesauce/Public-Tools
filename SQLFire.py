#CODE FOR QUERYING SQL INTO A CSV OR PANDAS DATAFRAM

import csv, pyodbc
import pandas as pd

##WRITE OUT TO A CSV
def SQLFireCSV(server,database,destTable,SQLQuery):
    cnxn = pyodbc.connect('DRIVER={SQL Server Native Client 11.0};SERVER='+server+';DATABASE='+database+';Trusted_Connection=yes;unicode_results: False')
    print "Connected to: " + server
    print "Database: " + database
    cursor = cnxn.cursor()
    cursor.execute("SET NOCOUNT ON;")
    print "Excecuting query..."
    cursor.execute(SQLQuery)
    c = csv.writer(open(destTable,"wb"))
    c.writerow([x[0] for x in cursor.description])
    for row in cursor:
        c.writerow(row)      

        
#FILL OUT THESE VARIABLES BELOW
SQLFire(myServ,myDB,myCSV.csv,"""

SELECT * FROM [My].[SQL].[TABLE]

""")

##WRITE OUT TO A PANDAS DATAFRAME
def SQLFirePandas(server,database,SQLQuery):
    cnxn = pyodbc.connect('DRIVER={SQL Server Native Client 11.0};SERVER='+server+';trusted_connection=yes;unicode_results: False')
    print "Connected to: " + server
    print "Database: " + database
    cursor = cnxn.cursor()
    cursor.execute("SET NOCOUNT ON;")
    print "Excecuting query..."

    df = pd.read_sql(SQLQuery, cnxn)
        
        
