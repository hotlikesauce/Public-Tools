import csv, pyodbc

def SQLFire(server,database,destTable,SQLQuery):
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
