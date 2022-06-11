extends Control



func _ready():
# warning-ignore:return_value_discarded
	GlobalTime.connect("InitSecond",self,"InitSecond")
# warning-ignore:return_value_discarded
	GlobalTime.connect("TimeModeChangedTo",self,"TimeModeChangedTo")
	InitCurrentStatus()
	
func InitCurrentStatus():
	var CurDate = OS.get_datetime()
	var CurDay = GlobalSave.LoadSpecificFile(CurDate["month"],CurDate["year"])
	var TotChecks = 0
	var CurCheck = 1
	for x in CurDay:
		if x == CurDate["day"]:
			while CurDay[x].has("check_in"+String(CurCheck)):
				TotChecks += 1
				GlobalTime.AddRetroTimeChange(GlobalTime.TIME_CHECKED_IN,CurDay[x]["check_in"+String(CurCheck)])
				if CurDay[x].has("check_out"+String(CurCheck)):
					GlobalTime.AddRetroTimeChange(GlobalTime.TIME_PAUSED,CurDay[x]["check_out"+String(CurCheck)])
					TotChecks -= 1
				CurCheck += 1
				
	if TotChecks >= 1:
		TimeModeChangedTo(GlobalTime.TIME_CHECKED_IN)
	else:
		if CurCheck == 1:
			TimeModeChangedTo(GlobalTime.TIME_IDLE)
		else:
			TimeModeChangedTo(GlobalTime.TIME_PAUSED)
# warning-ignore:unused_argument
func TimeModeChangedTo(ToMode):
	match ToMode:
		GlobalTime.TIME_IDLE:
			$ResumeBtn.visible = false
			$PauseBtn.visible = false
			$CheckOutBtn.visible = false
			$CheckinBtn.visible = true
			$CheckedInText.text = ""
			$PassedTime.text = ""
		GlobalTime.TIME_CHECKED_IN:
			$ResumeBtn.visible = false
			$CheckedInText.text = "Check In ("+ GlobalTime.ShowTime()+")"
			$CheckinBtn.visible = false
			$CheckOutBtn.visible = true
			$PauseBtn.visible = true
			AnimateCheckIn()
			InitSecond()
		GlobalTime.TIME_PAUSED:
			$ResumeBtn.visible = true
			$PauseBtn.visible = false
			$CheckOutBtn.visible = false
			$CheckedInText.text = "Auto Check-out end of the day"
			
	

func _on_CheckinBtn_pressed():
	GlobalTime.ChangeTimeModes(GlobalTime.TIME_CHECKED_IN)
	

func AnimateCheckIn():
	$CheckedInText.text = "Check In ("+ GlobalTime.ShowTime()+")"
	$CheckinBtn.visible = false
	$CheckOutBtn.visible = true
	$PauseBtn.visible = true
	
func InitSecond():
	if GlobalTime.CurTimeMode != GlobalTime.TIME_CHECKED_IN: return
	$PassedTime.text = "Passed Time: "+GlobalTime.CalcAllTimePassed()


func _on_PauseBtn_pressed():
	GlobalTime.ChangeTimeModes(GlobalTime.TIME_PAUSED)



func _on_ResumeBtn_pressed():
	GlobalTime.ChangeTimeModes(GlobalTime.TIME_CHECKED_IN)


func _on_CheckOutBtn_pressed():
	GlobalTime.ChangeTimeModes(GlobalTime.TIME_PAUSED)
