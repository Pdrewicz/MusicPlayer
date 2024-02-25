import sys
import json
import os

f = open("LOCALusers.json","r")
users = json.load(f)
f.close()

exists = False
for user in users["users"]:
    if user["name"] == sys.argv[1]:
        exists = True

if not exists:
    os.mkdir("/var/www/html/users/"+sys.argv[1])

    f = open("LOCALusers.json","r")
    users = json.load(f)
    f.close()
    users["users"].append({"name":sys.argv[1],"songs":[]})
    f = open("LOCALusers.json", "w")
    f.write(json.dumps(users))
    f.close()