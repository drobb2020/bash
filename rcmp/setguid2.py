#!/usr/bin/env python

import sys

#filename = str(sys.argv[1])
filename = "/_admin/Manage_NSS/manage.cmd"

file = open(filename,'r+')

initvfs = "<virtualIO><datastream name=\"command\"/></virtualIO>"
xmlrequest = "<nssRequest><dfs><setDfsGUID><volumeName>NCR_DATA1_PR</volumeName><dfsGUID/></setDfsGUID></dfs></nssRequest>"
file.write(initvfs)
file.write(xmlrequest)

file.seek(0)

xmlreply = file.read()

print xmlreply

file.close()

