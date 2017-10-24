import os
rootdir = 'music'
list = os.listdir(rootdir) 
for i in range(0,len(list)):
	path = os.path.join(rootdir,list[i])
	if not os.path.isfile(path):
		print(path)
		file_list = os.listdir(path + "/stingers")
		for file in file_list:
			open(path + "/stingers/" + file, "wb").write(open("null.vsnd_c", "rb").read())		

