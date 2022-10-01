extends HBoxContainer


var FirstIdle = false

func _ready():
# warning-ignore:return_value_discarded
	get_tree().connect("idle_frame",self,"GetIdleFrame")
	
func GetIdleFrame():
	if FirstIdle:
		return
	FirstIdle = true
	CheckForWhatsNew()


func CheckForWhatsNew():
	var F = File.new()
	F.open("res://ToDoList/ToDo.info",File.READ)
	var T = F.get_as_text()
	F.close()
	#print(T)
	var LastVersion = T.split("\n")[0].replace("Version ","")
	LastVersion = LastVersion.replace(":","")
	var S = GlobalSave.GetValueFromSettingCategory("WhatsNew")
	if S == null:
		GenerateIconedBtn("res://Assets/Icons/whats-new.png","WhatsNew",{"version":LastVersion,"Rich":T})
	else:
		if S["version"] != LastVersion:
			GenerateIconedBtn("res://Assets/Icons/whats-new.png","WhatsNew",{"version":LastVersion,"Rich":T})

func GenerateIconedBtn(TexturePath,FuncName,dict):
	var T = TextureRect.new()
	T.rect_min_size = Vector2(rect_min_size.y,rect_min_size.y)
	T.expand = true
	T.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	T.texture = load(TexturePath)
	T.material = load("res://Prefabs/Shaders/IconContainer.tres")
	add_child(T)
	T.connect("gui_input",self,"PressedOnBtn",[T,FuncName,dict])

func PressedOnBtn(event,_TextureNode,FuncName,dict):
	if event is InputEventMouseButton:
		if event.pressed:
			match FuncName:
				"WhatsNew":
					var PopupData = {"type": "WhatsNew","Title":"Whats new","Rich":dict["Rich"]}
					var Answer = yield(GlobalTime.ShowPopup(PopupData),"completed")

					match Answer:
						"DismissBtn":
							GlobalSave.AddVarsToSettings("WhatsNew","version",dict["version"])
							_TextureNode.queue_free()
						"CloseBtn":
							pass
