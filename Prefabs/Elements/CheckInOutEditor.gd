extends Panel

var CurEditor = null
var CurLabelEdit = null
var CurCheckInInfo = {}
var CurCheckOutInfo = {}
var CurCheckinNum = 0
var has_check_out = false

func _ready():
	modulate = Color(1,1,1,0)
	HideAllEditors()
	
func HideAllEditors():
	for x in get_children():
		if x is LineEdit:
			x.visible = false
			x.virtual_keyboard_enabled = false
		elif x is Label:
			if "Edit" in x.name:
				x.mouse_filter = Control.MOUSE_FILTER_PASS
				x.connect("gui_input",self,"SelectHour",[x])

func ShowDate(Delay,_Day,Info,Checks):
	CurCheckInInfo = Info["check_in"+String(Checks)]
	if Info.has("check_out"+String(Checks)):
		CurCheckOutInfo = Info["check_out"+String(Checks)]
		has_check_out = true
		
		#var p = GlobalTime.CalcTimePassed(Info["check_in"+String(Checks)],Info["check_out"+String(Checks)])
		#$HowLongWorked.text = TranslationServer.translate("Working Time").format([p,""])
	else:
		has_check_out = false
		$HowLongWorked.text = "no_check_out_yet"
	$DelayTimer.start(Delay)
	CurCheckinNum = Checks
	var CheckStr = String(Checks)
	if CheckStr.length() == 1:
		CheckStr = "0"+CheckStr
	$CheckInNum.text = CheckStr
	
# warning-ignore:unused_variable
	var CheckInDate = Info["check_in"+String(Checks)]
# warning-ignore:unused_variable
	if has_check_out:
		
		$CheckOutHourEdit.text = String(Info["check_out"+String(Checks)]["hour"])
		var Min = String(Info["check_out"+String(Checks)]["minute"])
		if Min.length()==1:
			Min = "0"+Min
		$CheckOutMinuteEdit.text = Min
	else:
		$CheckOutHourEdit.visible = false
		$CheckOutMinuteEdit.visible = false
		$CheckOutName.visible = false
		$RemoveButton.visible = false
	
	$CheckInHourEdit.text = String(Info["check_in"+String(Checks)]["hour"])
	var Min = String(Info["check_in"+String(Checks)]["minute"])
	if Min.length()==1:
		Min = "0"+Min
		
	
	$CheckInMinuteEdit.text = Min
	UpdateHowLongWorkd()
	
func UpdateHowLongWorkd():
	if !$CheckOutHourEdit.visible:
		$HowLongWorked.text = TranslationServer.translate("no_check_out_yet")
		return
	var CheckInHour = int($CheckInHourEdit.text)
	var CheckInMinute = int($CheckInMinuteEdit.text)
	
	var CheckOutHour = int($CheckOutHourEdit.text)
	var CheckOutMinute = int($CheckOutMinuteEdit.text)
	var data_in = {"hour":CheckInHour,"minute":CheckInMinute}
	var data_out = {"hour":CheckOutHour,"minute":CheckOutMinute}
	var p = GlobalTime.CalcTimePassedFull(data_in,data_out)
	$HowLongWorked.text = TranslationServer.translate("Working Time").format([p,""])
	
	
func HideAllEdits():
	for x in get_children():
		if x is LineEdit:
			x.visible = false
		elif x is Label:
			if "Edit" in x.name:
				if has_check_out:
					x.visible = true
				elif "In" in x.name:
					x.visible = true
					
				
func SelectHour(event,itmNode):
	if event is InputEventMouseButton:
		if event.pressed:
			if CurEditor != null:
				if CurEditor.has_focus():
					UpdateCurEditor()
				else:
					HideAllEdits()
			else:
				HideAllEdits()
			var n = get_node(itmNode.name+"or")
			GlobalTime.ShowKeypad(self,"OnEntry",".")
			
			n.visible = true
			itmNode.visible = false
			n.placeholder_text = itmNode.text
			n.text = ""
			CurEditor = n
			CurLabelEdit = itmNode
			CurEditor.caret_position = CurEditor.text.length()

func OnEntry(Key):
	match Key:
		"<":
			if CurEditor.text.length() > 0:
				CurEditor.text = CurEditor.text.substr(0,CurEditor.text.length()-1)
		"ENT","TAP_OUTSIDE":
			CurEditor.visible = false
			if CurEditor.text.is_valid_integer():
				UpdateCurEditor()
				UpdateHowLongWorkd()
			else:
				CurLabelEdit.visible = true
		"CLS":
			CurEditor.visible = false
			CurLabelEdit.visible = true
		_:
			CurEditor.text += Key
	CurEditor.caret_position = CurEditor.text.length()


func GetEditedInfo():
	var CheckInNum = int($CheckInNum.text)
	var Res = {}
	Res["check_in"+String(CheckInNum)] = {}
	if has_check_out:
		Res["check_out"+String(CheckInNum)] = {}
	
	Res["check_in"+String(CheckInNum)]["year"] = CurCheckInInfo["year"]
	Res["check_in"+String(CheckInNum)]["month"] = CurCheckInInfo["month"]
	Res["check_in"+String(CheckInNum)]["day"] = CurCheckInInfo["day"]
	Res["check_in"+String(CheckInNum)]["hour"] = int($CheckInHourEdit.text)
	Res["check_in"+String(CheckInNum)]["minute"] = int($CheckInMinuteEdit.text)
	Res["check_in"+String(CheckInNum)]["second"] = 0
	
	if has_check_out:
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

				
func UpdateCurEditor():
	if CurEditor.text.is_valid_integer():
		if "Hour" in CurEditor.name:
			if int(CurEditor.text) <= 48 && int(CurEditor.text)>=0:
				CurLabelEdit.text = CurEditor.text
			elif int(CurEditor.text) > 48:
				CurLabelEdit.text = "48"
		elif "Minute" in CurEditor.name:
			if int(CurEditor.text) <= 60 && int(CurEditor.text)>=0:
				CurLabelEdit.text = CurEditor.text
			elif int(CurEditor.text) > 60:
				CurLabelEdit.text = "60"
	HideAllEdits()

func _on_RemoveButton_pressed():
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"FinishTweenAndClose",[T])
	T.interpolate_property(self,"modulate",modulate,Color(1,1,1,0),0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	T.start()
	
func FinishTweenAndClose(T):
	T.queue_free()
	GlobalSave.RemoveCheckInOut(CurCheckinNum,CurCheckInInfo)
	var Date= {"year":GlobalTime.CurSelectedDate["year"],"month":GlobalTime.CurSelectedDate["month"],"day":GlobalTime.CurSelectedDate["day"]}
	get_parent().get_parent().SyncDate(Date,"")
	GlobalTime.emit_signal("NoAnimShowWindow","HourEditorScreen")
	GlobalTime.emit_signal("UpdateDayInfo")
