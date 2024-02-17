import os
import io
from googleapiclient.http import MediaIoBaseDownload
from Google import Create_Service
import sys
import json

os.remove("./users/"+sys.argv[1]+"/"+sys.argv[2])