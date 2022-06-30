extends Control



func _ready():
# warning-ignore:return_value_discarded
	GlobalTime.connect("InitSecond",self,"InitSecond")
# warning-ignore:return_value_discarded
	GlobalTime.connect("TimeModeChangedTo",self,"TimeModeChangedTo")
# warning-ignore:return_value_discarded
	GlobalSave.connect("UpdateToday",self,"UpdateToday")
	InitCurrentStatus()
	

func InitCurrentStatus():
	var CurDate = OS.get_datetime()
	var CurDay = GlobalSave.LoadSpecificFile(CurDate["month"],CurDate["year"])
	var TotChecks = 0
	var CurCheck = 1
	$HolidayToday.visible = false
	if CurDay != null:
		for x in CurDay:
			if x == CurDate["day"]:
				if CurDay[x].has("report"):
					$HolidayToday.visible = true
					ShowDayOff(CurDay[x]["report"])
				else:
					
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

func UpdateToday():
	var CurDate = OS.get_datetime()
	var CurDay = GlobalSave.LoadSpecificFile(CurDate["month"],CurDate["year"])
	$HolidayToday.visible = false
	if CurDay != null:
		for x in CurDay:
			if x == CurDate["day"]:
				if CurDay[x].has("report"):
					$HolidayToday.visible = true
					ShowDayOff(CurDay[x]["report"])
					
func ShowDayOff(Data):
	if Data == null:
		$HolidayToday.visible = false
		return
	$HolidayToday/TextureButton.texture = GlobalSave.ReportToImage(Data)
	$HolidayToday/Holiday.text = TranslationServer.translate("today_is_my") % TranslationServer.translate(Data)
	
# warning-ignore:unused_argument
func TimeModeChangedTo(ToMode):
	match ToMode:
		GlobalTime.TIME_IDLE:
			$StartStopBtn.ForceToggle(false)
			$CheckedInText.text = ""
			$PassedTime.text = ""
			SyncNosafot()
		GlobalTime.TIME_CHECKED_IN:
			$CheckedInText.text = TranslationServer.translate("check_in_info") % GlobalTime.ShowTime()
			$StartStopBtn.ForceToggle(true)
			InitSecond()
		GlobalTime.TIME_PAUSED:
			$StartStopBtn.ForceToggle(false)
			var StartedWorking = GlobalTime.GetLastCheckIn()
			var EndedWorking = GlobalTime.GetLastCheckOut()
			var PassedTime = GlobalTime.CalcAllCheckInsAndOutsToSeconds()
			$PassedTime.text = TranslationServer.translate("worked_today_info") % GlobalTime.TimeToString(PassedTime)
			#var EndedWorking = GlobalTime.
			var In_Min = String(StartedWorking["minute"])
			var Out_Min = String(EndedWorking["minute"])
			if In_Min.length()==1:
				In_Min = "0"+In_Min
			if Out_Min.length() == 1:
				Out_Min = "0"+Out_Min
			$CheckedInText.text = TranslationServer.translate("checked_out_info") % [String(StartedWorking["hour"])+":"+In_Min+ " -> " +String(EndedWorking["hour"])+":"+Out_Min]
			SyncNosafot()
	

func _on_CheckinBtn_pressed():
	GlobalTime.ChangeTimeModes(GlobalTime.TIME_CHECKED_IN)
	
func SyncNosafot():
	var Nosafot = GlobalSave.GetValueFromSettingCategory("SalaryDeduction")
	var WorkHours = GlobalSave.GetValueFromSettingCategory("WorkingHours")
	var has_125 = false
	var has_150 = false
	if Nosafot != null && WorkHours != null:
		if Nosafot.has("overtime125"):
			has_125 = Nosafot["overtime125"]
		if Nosafot.has("overtime150"):
			has_150 = Nosafot["overtime150"]
			
	var PassedTime = GlobalTime.CalcAllCheckInsAndOutsToSeconds()
	$Nosafot150Info.text = ""
	var Worked125 = 0
	var Worked150 = 0
	if has_125:
		if PassedTime> WorkHours["hours"] * 3600:
			Worked125 = PassedTime - (WorkHours["hours"] * 3600)
			if Worked125 > 2*3600:
				Worked125 = 2*3600
	if has_150:
		if PassedTime > (WorkHours["hours"]+2) * 3600:
			Worked150 = PassedTime - ((WorkHours["hours"]+2) * 3600)
			
	if Worked125 == 0:
		$Nosafot125Info.text = ""
	else:
		$Nosafot125Info.text = TranslationServer.translate("Overtime 125").format([GlobalTime.TimeToString(Worked125)])
		
	if Worked150 == 0:
		$Nosafot150Info.text = ""
	else:
		$Nosafot150Info.text = TranslationServer.translate("Overtime 150").format([GlobalTime.TimeToString(Worked150)])
	
func InitSecond():
	if GlobalTime.CurTimeMode != GlobalTime.TIME_CHECKED_IN: return
	var CurDate = GlobalTime.CalcAllTimePassed()
	$PassedTime.text = TranslationServer.translate("passed_time_info") % CurDate
	SyncNosafot()


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
		


func _on_StartStopBtn_pressed():
	var TodayReport = GlobalSave.HasTodayReport()
	if TodayReport != null:
		var PopupData = {"type": "YesNo","title":"","desc":TranslationServer.translate("are_you_sure_to_skip") % TranslationServer.translate(TodayReport)}
		GlobalTime.PopupModulateUI.ShowModulate(PopupData)
		$StartStopBtn.DontFlip = true
		var Answer = yield(GlobalTime.PopupModulateUI,"EmitedAnswer")
		
		match Answer:
			"No":
				pass
			"Yes":
				var Date = OS.get_datetime()
				GlobalSave.RemoveReport(Date)
				GlobalSave.emit_signal("UpdateToday")
				$StartStopBtn.BtnPressed()
				#$StartStopBtn.DontFlip = true
	#GlobalTime.PopupModulateUI.ShowModulate(null)
