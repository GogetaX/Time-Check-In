extends Panel

var CurEditor = null
var CurLabelEdit = null
var CurCheckInInfo = {}
var CurCheckOutInfo = {}

func _ready():
	modulate = Color(1,1,1,0)
	HideAllEditors()
	
func HideAllEditors():
	$InteractiveButton.visible = false
	for x in get_children():
		if x is LineEdit:
			x.visible = false
		elif x is Label:
			if "Edit" in x.name:
				x.mouse_filter = Control.MOUSE_FILTER_PASS
				x.connect("gui_input",self,"SelectHour",[x])

func ShowDate(Delay,_Day,Info,Checks):
	CurCheckInInfo = Info["check_in"+String(Checks)]
	CurCheckOutInfo = Info["check_out"+String(Checks)]
	$DelayTimer.start(Delay)
	var CheckStr = String(Checks)
	if CheckStr.length() == 1:
		CheckStr = "0"+CheckStr
	$CheckInNum.text = CheckStr
	
# warning-ignore:unused_variable
	var CheckInDate = Info["check_in"+String(Checks)]
# warning-ignore:unused_variable
	var CheckOutDate = Info["check_out"+String(Checks)]
	
	$CheckInHourEdit.text = String(Info["check_in"+String(Checks)]["hour"])
	$CheckInMinuteEdit.text = String(Info["check_in"+String(Checks)]["minute"])
	
	$CheckOutHourEdit.text = String(Info["check_out"+String(Checks)]["hour"])
	$CheckOutMinuteEdit.text = String(Info["check_out"+String(Checks)]["minute"])

func HideAllEdits():
	$InteractiveButton.visible = false
	for x in get_children():
		if x is LineEdit:
			x.visible = false
		elif x is Label:
			if "Edit" in x.name:
				x.visible = true
				
func SelectHour(event,itmNode):
	if event is InputEventMouseButton:
		if event.pressed:
			if CurEditor != null:
				if CurEditor.has_focus():
					_on_InteractiveButton_pressed()
				else:
					HideAllEdits()
			else:
				HideAllEdits()
			$InteractiveButton.visible = true
			var n = get_node(itmNode.name+"or")
			n.visible = true
			itmNode.visible = false
			n.placeholder_text = itmNode.text
			n.text = ""
			n.grab_focus()
			CurEditor = n
			CurLabelEdit = itmNode


func _on_InteractiveButton_pressed():
	if CurEditor.text.is_valid_integer():
		if "Hour" in CurEditor.name:
			if int(CurEditor.text) <= 24 && int(CurEditor.text)>=0:
				CurLabelEdit.text = CurEditor.text
		elif "Minute" in CurEditor.name:
			if int(CurEditor.text) <= 60 && int(CurEditor.text)>=0:
				CurLabelEdit.text = CurEditor.text
	HideAllEdits()

func GetEditedInfo():
	var CheckInNum = int($CheckInNum.text)
	var Res = {}
	Res["check_in"+String(CheckInNum)] = {}
	Res["check_out"+String(CheckInNum)] = {}
	
	Res["check_in"+String(CheckInNum)]["year"] = CurCheckInInfo["year"]
	Res["check_in"+String(CheckInNum)]["month"] = CurCheckInInfo["month"]
	Res["check_in"+String(CheckInNum)]["day"] = CurCheckInInfo["day"]
	Res["check_in"+String(CheckInNum)]["hour"] = int($CheckInHourEdit.text)
	Res["check_in"+String(CheckInNum)]["minute"] = int($CheckInMinuteEdit.text)
	Res["check_in"+String(CheckInNum)]["second"] = 0
	
	Res["check_out"+String(CheckInNum)]["year"] = CurCheckOutInfo["year"]
	Res["check_out"+String(CheckInNum)]["month"] = CurCheckOutInfo["month"]
	Res["check_out"+String(CheckInNum)]["day"] = CurCheckOutInfo["day"]
	Res["check_out"+String(CheckInNum)]["hour"] = int($CheckOutHourEdit.text)
	Res["check_out"+String(CheckInNum)]["minute"] = int($CheckOutMinuteEdit.text)
	Res["check_out"+String(CheckInNum)]["second"] = 0
	return Res

func _on_DelayTimer_timeout():
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"FinishTween",[T])
	T.interpolate_property(self,"modulate",Color(1,1,1,0),Color(1,1,1,1),0.2,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	T.start()
	
func FinishTween(T):
	T.queue_free()
