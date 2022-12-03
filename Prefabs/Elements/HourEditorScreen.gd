extends Control

var CheckInEditorInstance = preload("res://Prefabs/Elements/CheckInOutEditor.tscn")

var CurDate = {}
var CustomShowScreen = "CalendarScreen"

func _ready():
# warning-ignore:return_value_discarded
	connect("visibility_changed",self,"visibility_changed")
	
func visibility_changed():
	if visible:
		GlobalTime.SwipeEnabled = false

func SyncDate(EditingDate,CloseToScreen = "CalendarScreen"):
	CustomShowScreen = CloseToScreen
	$TopMenu/Accept.focus_mode = Control.FOCUS_NONE
	$TopMenu/Decline.focus_mode = Control.FOCUS_NONE
	for x in $VBoxContainer.get_children():
		x.queue_free()
	
	CurDate = EditingDate
	var Delay = 0.1
	var DateToEdit = GlobalSave.LoadSpecificFile(CurDate["month"],CurDate["year"])
	for x in DateToEdit:
		if x == CurDate["day"]:
			var Checks = 1
			while DateToEdit[x].has("check_in"+String(Checks)):
				var CheckInEditor = CheckInEditorInstance.instance()
				$VBoxContainer.add_child(CheckInEditor)
				CheckInEditor.ShowDate(Delay,x,DateToEdit[x],Checks)
				Delay+=0.1
				
				Checks += 1
	$TopMenu/Title.text = GlobalTime.DisplayFullDate(CurDate)


func _on_Decline_pressed():
	GlobalTime.SwipeEnabled = true
	GlobalTime.FreeTool(self)
	get_parent().ShowOnly(CustomShowScreen)

func _on_Accept_pressed():
	var is_today = CheckIfToday(GlobalTime.CurSelectedDate)
	if is_today:
		GlobalSave.ClearAllData()
	for x in $VBoxContainer.get_children():
		var Checks = x.GetEditedInfo()
		for a in Checks:
			GlobalSave.MySaves[GlobalTime.CurSelectedDate["year"]][GlobalTime.CurSelectedDate["month"]][GlobalTime.CurSelectedDate["day"]][a] = Checks[a]
			if is_today:
				if "check_in" in a:
					GlobalTime.HasCheckin.append(Checks[a])
				elif "check_out" in a:
					GlobalTime.HasCheckOut.append(Checks[a])
				else:
					print("Error: HourEditorScreen.gd->_on_Accept_pressed() problem with Checkin/out? ",a)
				#GlobalTime.HasCheckOut.append()
		#GlobalSave.MySaves[GlobalTime.CurSelectedDate["year"]][GlobalTime.CurSelectedDate["month"]][GlobalTime.CurSelectedDate["day"]] = Checks
		GlobalSave.SaveToFile()
		
	GlobalTime.emit_signal("ReloadCurrentDate")
	GlobalTime.emit_signal("UpdateList")
	
	GlobalTime.SyncCurDay(GlobalTime.CurSelectedDate)
	_on_Decline_pressed()

func CheckIfToday(Date):
	var CurDay = OS.get_datetime()
	if CurDay["day"] == Date["day"] && CurDay["month"] == Date["month"] && CurDay["year"] == Date["year"]:
		return true
	return false
