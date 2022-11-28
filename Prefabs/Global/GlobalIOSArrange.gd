extends Node

var UserPath = "user://"

func _ready():
	RearangeFilesForiOS()
	
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
	UserPath = GetiOSLibraryPath()
	if OS.get_name() == "iOS":
		var files = []
		var dir = Directory.new()
		dir.open("user://")
		dir.list_dir_begin()

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
