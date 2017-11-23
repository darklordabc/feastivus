import os
rootdir = 'vo'
list = os.listdir(rootdir) 
for i in range(0,len(list)):
	path = os.path.join(rootdir,list[i])
	if not os.path.isfile(path):
		print(path)
		file_list = os.listdir(path + "/")
		for file in file_list:
			filepath = os.path.join(path, file)
			open(filepath, "wb").write(open("null.vsnd_c", "rb").read())		

