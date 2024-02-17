import subprocess
import sys
import os
import time
import shutil

name = sys.argv[1]

link = sys.argv[2]

playerName = sys.argv[3]

args = ['./yt-dlp_linux', '-o', '/var/www/html/download/'+name+'.webm', link]
subprocess.call(args)

args = ['ffmpeg-git-20240112-amd64-static/ffmpeg', '-i', './download/'+name+'.webm', '-ac', '1', '-c:a', 'dfpwm', './converted/'+name+'.dfpwm', '-ar', '48k','-y']
subprocess.call(args)

#shutil.copy("./converted"+"/"+name+".dfpwm","./users"+"/"+playerName+"/"+name+".dfpwm")

#path = r"./download"
#f = path+"/"+name+".webm"
#if os.path.isfile(f):
#	os.remove(f)

#path = r"./converted"
#f = path+"/"+name+".dfpwm"
#if os.path.isfile(f):
#	os.remove(f)