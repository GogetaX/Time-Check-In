extends Control

var FileBtn

func SyncDebug():
	FileBtn = $HBoxContainer/Button.duplicate()
	$HBoxContainer/Button.queue_free()
	ShowFileList()


func ShowFileList():
	var files = []
	var dir = Directory.new()
	dir.open("user://")
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)

	dir.list_dir_end()
	for x in files:
		if ".sf" in x:
			var btn = FileBtn.duplicate()
			btn.text = x
			$HBoxContainer.add_child(btn)
			btn.connect("pressed",self,"btn_pressed",[x])
		$FileList.text += x+"\n"
	return

func btn_pressed(txt):
	var a = LoadFile(txt)
	$List.text = String(a)
	
func LoadFile(FName):
	var Res = null
	var F = File.new()
	if F.file_exists("user://"+FName):
		F.open("user://"+FName,File.READ)
		Res = F.get_var()
	
	F.close()
	return Res
