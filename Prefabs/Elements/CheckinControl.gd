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
	if CurDay != null:
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
			$StartStopBtn.ForceToggle(false)
			$CheckedInText.text = ""
			$PassedTime.text = ""
		GlobalTime.TIME_CHECKED_IN:
			$CheckedInText.text = "Check In ("+ GlobalTime.ShowTime()+")"
			$StartStopBtn.ForceToggle(true)
			InitSecond()
		GlobalTime.TIME_PAUSED:
			$StartStopBtn.ForceToggle(false)
			var StartedWorking = GlobalTime.GetLastCheckIn()
			var EndedWorking = GlobalTime.GetLastCheckOut()
			#var EndedWorking = GlobalTime.
			$CheckedInText.text = "Checked out (" +String(StartedWorking["hour"])+":"+String(StartedWorking["minute"])+ " -> " +String(EndedWorking["hour"])+":"+String(EndedWorking["minute"])+")"
			
	

func _on_CheckinBtn_pressed():
	GlobalTime.ChangeTimeModes(GlobalTime.TIME_CHECKED_IN)
	

	
func InitSecond():
	if GlobalTime.CurTimeMode != GlobalTime.TIME_CHECKED_IN: return
	$PassedTime.text = "Passed Time: "+GlobalTime.CalcAllTimePassed()


func _on_PauseBtn_pressed():
	GlobalTime.ChangeTimeModes(GlobalTime.TIME_PAUSED)



func _on_ResumeBtn_pressed():
	GlobalTime.ChangeTimeModes(GlobalTime.TIME_CHECKED_IN)


func _on_CheckOutBtn_pressed():
	GlobalTime.ChangeTimeModes(GlobalTime.TIME_PAUSED)


func _on_StartStopBtn_Toggled():
	if $StartStopBtn.is_Toggled:
		GlobalTime.ChangeTimeModes(GlobalTime.TIME_CHECKED_IN)
	else:
		GlobalTime.ChangeTimeModes(GlobalTime.TIME_PAUSED)
