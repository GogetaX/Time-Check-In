extends Control

var CheckInEditorInstance = preload("res://Prefabs/Elements/CheckInOutEditor.tscn")

var CurDate = {}
func _ready():
	GlobalTime.HourSelectorUI = self

func SyncDate(EditingDate):
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
	get_parent().ShowOnly("CalendarScreen")


func _on_Accept_pressed():
	for x in $VBoxContainer.get_children():
		var Checks = x.GetEditedInfo()
		for a in Checks:
			GlobalSave.MySaves[GlobalTime.CurSelectedDate["year"]][GlobalTime.CurSelectedDate["month"]][GlobalTime.CurSelectedDate["day"]][a] = Checks[a]
		#GlobalSave.MySaves[GlobalTime.CurSelectedDate["year"]][GlobalTime.CurSelectedDate["month"]][GlobalTime.CurSelectedDate["day"]] = Checks
		GlobalSave.SaveToFile()
	GlobalTime.emit_signal("ReloadCurrentDate")
	_on_Decline_pressed()
