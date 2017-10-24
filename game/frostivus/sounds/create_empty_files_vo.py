import os
rootdir = 'music/valve_dota_001/music'
list = os.listdir(rootdir) 
for i in range(0,len(list)):
	path = os.path.join(rootdir,list[i])
	if os.path.isfile(path):
		print("finished", path)
		open(path, "wb").write(open("null.vsnd_c", "rb").read())
		

