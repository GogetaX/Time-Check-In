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
	var LastVersion = null
	var VersionList = {}
	var CurVer = null
	for x in T.split("\n"):
		if x.begins_with("Version"):
			CurVer = x.replace("Version ","")
			CurVer = CurVer.replace(":","")
			if LastVersion == null && CurVer != "TODO":
				LastVersion = CurVer
		else:
			if x != "" && CurVer != null:
				if !VersionList.has(CurVer):
					VersionList[CurVer] = "Version "+CurVer+":\n"+x
				else:
					VersionList[CurVer] = VersionList[CurVer]+"\n"+x

	if LastVersion == null:
		return
	var S = GlobalSave.GetValueFromSettingCategory("WhatsNew")
	if S == null:
		GenerateIconedBtn("res://Assets/Icons/whats-new.png","WhatsNew",{"version":LastVersion,"Rich":VersionList[LastVersion]})
	else:
		if S["version"] != LastVersion:
			GenerateIconedBtn("res://Assets/Icons/whats-new.png","WhatsNew",{"version":LastVersion,"Rich":VersionList[LastVersion]})
	
	var RateMe = GlobalSave.GetValueFromSettingCategory("RateMe")
	if RateMe == null:
		GenerateIconedBtn("res://Assets/Icons/star.png","RateMe",{"Rich":"rate_me_msg"})
	else:
		if RateMe.has("date"):
			var d = GlobalTime.GetDifferenceBetweenDates(OS.get_date(),RateMe["date"])
			var days = GlobalTime.DateToDays(d)
			if days > 30*6: #if 6 months passed, show rate me msg again
				GenerateIconedBtn("res://Assets/Icons/star.png","RateMe",{"Rich":"rate_me_msg"})
			
func GenerateIconedBtn(TexturePath,FuncName,dict = null):
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
				"RateMe":
					var PopupData = {"type": "RateMe"}
					var Answer = yield(GlobalTime.ShowPopup(PopupData),"completed")
					match Answer:
						"DismissBtn":
							GlobalSave.AddVarsToSettings("RateMe","date",OS.get_date())
							_TextureNode.queue_free()
							match OS.get_name():
								"Windows":
									# warning-ignore:return_value_discarded
									OS.shell_open("https://play.google.com/store/apps/details?id=org.godotengine.timecheckin")
								"Android":
									# warning-ignore:return_value_discarded
									OS.shell_open("market://details?id=org.godotengine.timecheckin")
								"iOS":
									var txt = "itms-apps://itunes.apple.com/app/idtime-check-in?action=write-review"
									txt = txt.replace(" ","%20")
									# warning-ignore:return_value_discarded
									OS.shell_open(txt)
						"CloseBtn":
							pass
					
				_:
					print_debug("This is not set yet: ",FuncName)
