import os
from os.path import isfile
import io
from googleapiclient.http import MediaIoBaseDownload
from Google import Create_Service
import sys
import json

songs = []
for file in os.listdir("./users/"+sys.argv[1]):
	if isfile("./users/"+sys.argv[1]+"/"+file):
		songs.append(file)

f = open("LOCALusers.json","r")
users = json.load(f)
f.close()

for user in users["users"]:
	if user["name"] == sys.argv[1]:
		user["songs"] = songs

print(json.dumps(users))
f = open("LOCALusers.json","w")
f.write(json.dumps(users))
f.close()