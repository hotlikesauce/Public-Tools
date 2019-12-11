from arcgis.gis import GIS
import arcgis.gis.admin

gis = GIS("YOUR PORTAL URL", "USERNAME", "PASSWORD",verify_cert=False)
gis_servers = gis.admin.servers.list()
server1 = gis_servers[0]
server1.services.list()
folders = (server1.services.folders)
for folder in folders:
    hosted_services = server1.services.list(folder=folder)
    for service in hosted_services:
        service.start()
        print(f"Started: {service}")
        #service.stop()
        #print(f"Stopped: {service}")
