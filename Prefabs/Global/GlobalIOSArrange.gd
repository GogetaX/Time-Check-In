extends Node

var UserPath = "user://"

func _ready():
	RearangeFilesForiOS()
	IfDeveloperCreateFolderAndSendCopy()

#C5C6FE2C-0454-4B72-9781-54AB542EB87C
func IfDeveloperCreateFolderAndSendCopy():
	if OS.get_unique_id() == "C5C6FE2C-0454-4B72-9781-54AB542EB87C":
		var CopyPath = "user://SavedData/"
		var dir = DirAccess.open(CopyPath)
		#dir.make_dir_recursive(CopyPath)
		#dir.open(UserPath)
		dir.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var files = []
		
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif file.ends_with(".sf") || file.ends_with(".ini"):
				files.append(file)

		dir.list_dir_end()
		for x in files:
			dir.copy(UserPath+x,CopyPath+x)
		

	
func GetiOSLibraryPath():
	#/Users/sergiokirienko/Library/Developer/CoreSimulator/Devices/10672DE3-D6D4-409F-94FD-CCAA11573322/data/Containers/Data/Application/614E7B6F-A5DD-4B63-BAB8-5306F16F24FA/Documents/Documents/ExportCSV-18-11-2022.csv
	var res = ProjectSettings.globalize_path("user://")
	var d = res.split("/")
	var r = ""
	for x in d:
		if x == "Documents":
			return r+"/Library/"
		r = r + "/"+x
	return r
	
func RearangeFilesForiOS():
	if OS.get_name() == "iOS":
		UserPath = GetiOSLibraryPath()
		var files = []
		var dir = DirAccess.open("user://")
		#dir.open("user://")
		dir.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547

		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif file.ends_with(".sf") || file.ends_with(".ini"):
				files.append(file)

		dir.list_dir_end()
		dir.make_dir_recursive(UserPath)
		for x in files:
			dir.copy("user://"+x,UserPath+x)
			dir.remove("user://"+x)
