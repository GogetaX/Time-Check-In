extends Control

var HoldTween = Tween.new()

func _ready():
	add_child(HoldTween)
	HoldTween.connect("tween_all_completed",self,"FinishedWaitTween")
	GlobalSave.AddReportOptionsToNode($IdleOptions,true)
	GlobalSave.AddAditionalReportOptions($IdleOptions)
	$StartStopBtn/TextureProgress.visible = false
# warning-ignore:return_value_discarded
	GlobalTime.connect("InitSecond",self,"InitSecond")
# warning-ignore:return_value_discarded
	GlobalTime.connect("TimeModeChangedTo",self,"TimeModeChangedTo")
# warning-ignore:return_value_discarded
	GlobalSave.connect("UpdateToday",self,"UpdateToday")
# warning-ignore:return_value_discarded
	InitCurrentStatus()
	PopupForYesterday()
	PopupForSometimeAgo()
	$IdleOptions.get_popup().connect("index_pressed",self,"SelectedReport")
	
	
func PopupForSometimeAgo():
	if GlobalTime.ForgotCheckInSometimeAgo == null:
		return
	var Date = String(GlobalTime.ForgotCheckInSometimeAgo["day"])+"."+String(GlobalTime.ForgotCheckInSometimeAgo["month"])+"."+String(GlobalTime.ForgotCheckInSometimeAgo["year"])
	var PopupData = {"type": "ForgetCheckOutSomeTimeAgo","Desc":TranslationServer.translate("forgot_check_out_some_day") % Date}
	var Answer = yield(GlobalTime.ShowPopup(PopupData),"completed")
	match Answer:
		"EditBtn":
			GlobalTime.SelectCurDayList(GlobalTime.ForgotCheckInSometimeAgo,GlobalTime.ForgotCheckInSometimeAgo)
			var hour_editor = GlobalTime.LoadTool("Hour Editor")
			hour_editor.SyncDate(GlobalTime.ForgotCheckInSometimeAgo,"TimeScreen")
			GlobalTime.emit_signal("ShowOnlyScreen","HourEditorScreen")
		"CloseBtn":
			pass
	GlobalTime.ForgotCheckInSometimeAgo = null
	
func PopupForYesterday():
	var CurDay = OS.get_datetime()
	var Yesterday = GlobalTime.OffsetDay(CurDay,-1)
	if CurDay["month"] != Yesterday["month"] || CurDay["year"] != Yesterday["year"]:
		var _yest = GlobalSave.LoadSpecificFile(Yesterday["month"],Yesterday["year"],true)
	else:
		GlobalSave.AddMySavesPath(Yesterday)
	if !GlobalTime.ForgotCheckInYesterday:
		return
	var PopupData = {"type": "ForgetCheckOut"}
	var Answer = yield(GlobalTime.ShowPopup(PopupData),"completed")
	match Answer:
		"ContinueBtn":
			print("Pressed Continue")
			var CheckInDate = OS.get_datetime()
			CheckInDate["hour"] = 0
			CheckInDate["minute"] = 0
			CheckInDate["second"] = 1
			GlobalTime.AddRetroTimeChange(GlobalTime.TIME_RETRO_CHECK_IN,CheckInDate)
		"CheckOutBtn":
			print("Pressed Checkout")
	
	GlobalTime.ForgotCheckInYesterday = false

func InitCurrentStatus(report_only = false):
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
						if !report_only:
							GlobalTime.AddRetroTimeChange(GlobalTime.TIME_CHECKED_IN,CurDay[x]["check_in"+String(CurCheck)])
						if CurDay[x].has("check_out"+String(CurCheck)):
							if !report_only:
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
	InitCurrentStatus(true)
	

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
			$CheckedInText.text = TranslationServer.translate("check_in_info") % GlobalTime.ShowLastCheckIn()
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
		if $Nosafot125Info.visible:
			$Nosafot125Info.visible = false
		$Nosafot125Info.text = ""
	else:
		if !$Nosafot125Info.visible:
			$Nosafot125Info.visible = true
		$Nosafot125Info.text = TranslationServer.translate("Overtime 125").format([GlobalTime.TimeToString(Worked125)])
		
	if Worked150 == 0:
		if $Nosafot150Info.visible:
			$Nosafot150Info.visible = false
		$Nosafot150Info.text = ""
	else:
		if !$Nosafot150Info.visible:
			$Nosafot150Info.visible = true
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
		GlobalNotif.PushCheckOutReminder()
	else:
		GlobalNotif.ClearNotifications()
		GlobalTime.ChangeTimeModes(GlobalTime.TIME_PAUSED)
		


func _on_StartStopBtn_pressed():
	if $IdleOptions.get_popup().visible:
		return
	var TodayReport = GlobalSave.HasTodayReport()
	if TodayReport != null:
		var PopupData = {"type": "YesNo","Title":"","Desc":TranslationServer.translate("are_you_sure_to_skip") % GlobalHebrew.HebrewTextConvert(TranslationServer.translate(TodayReport),30)}
		$StartStopBtn.DontFlip = true
		
		var Answer = yield(GlobalTime.ShowPopup(PopupData),"completed")
		match Answer:
			"NoBtn":
				pass
			"YesBtn":
				var Date = OS.get_datetime()
				GlobalSave.RemoveReport(Date)
				GlobalSave.emit_signal("UpdateToday")
				$StartStopBtn.BtnPressed()
				#$StartStopBtn.DontFlip = true
	#GlobalTime.PopupModulateUI.ShowModulate(null)
	
func _on_StartStopBtn_button_down():
	if $StartStopBtn.is_Toggled:
		return
	HoldTween.remove_all()
	$StartStopBtn/TextureProgress.value = 0
	$StartStopBtn/TextureProgress.visible = true
	HoldTween.interpolate_property($StartStopBtn/TextureProgress,"value",0,100,0.8,Tween.TRANS_LINEAR,Tween.EASE_IN)
	HoldTween.start()


func _on_StartStopBtn_button_up():
	if HoldTween.is_active():
		HoldTween.remove_all()
		$StartStopBtn/TextureProgress.visible = false

func FinishedWaitTween():
	$StartStopBtn.DontFlip = true
	#$IdleOptions.visible = true
	$IdleOptions.ForceShowOnMouse(get_global_mouse_position())
	#$IdleOptions.get_popup().show_modal()
	#$IdleOptions.get_popup().rect_position = get_viewport_rect().size / 2

func SelectedReport(index):
	var report = ""
	report = $IdleOptions.get_popup().get_item_metadata(index)
	var CurData = OS.get_datetime()
	GlobalTime.SelectCurDayList(CurData,CurData)
	match report:
		"Forgot Check-in?":
			
			#GlobalSave.RemoveReport(Date)
			var CheckInDate = CurData.duplicate()
			var S = GlobalSave.GetValueFromSettingCategory("WorkingHours")
			if S != null:
				if S.has("minutes"):
					CheckInDate["minute"] -= S["minutes"]
				if S.has("hours"):
					CheckInDate["hour"] -= S["hours"]
				if CheckInDate["minute"] < 0:
					CheckInDate["hour"] -= 1
					CheckInDate["minute"] = 60 - CheckInDate["minute"]
				if CheckInDate["hour"] < 1:
					CheckInDate["hour"] = 1
				
			var CheckOutDate = CurData.duplicate()
			
			
			GlobalSave.AddCheckIn(CheckInDate)
			GlobalSave.AddCheckOut(CheckOutDate)
			
			GlobalTime.FillCheckInOutArray(CheckInDate,CheckOutDate)
			GlobalTime.emit_signal("UpdateSpecificDayInfo",CheckOutDate["day"],GlobalSave.MySaves[CheckOutDate["year"]][CheckOutDate["month"]][CheckOutDate["day"]])
			GlobalTime.SyncCurDay(CheckOutDate)
			
		#Edit working hours
			var hourUI = GlobalTime.LoadTool("Hour Editor")
			hourUI.SyncDate(CurData,"TimeScreen")
			#GlobalTime.emit_signal("ShowOnlyScreen","HourEditorScreen")
			GlobalTime.emit_signal("ShowOnlyScreen","HourEditorScreen")
			
		"Day off":
			var GetToday = GlobalSave.GetTodayInfo()
			if GetToday != null && GetToday.has("check_in1"):
				var PassedTime = GlobalHebrew.HebrewTextConvert(GlobalTime.CalcAllTimePassed(),30)
				var PopupData = {"type": "YesNo","Title":"","Desc":TranslationServer.translate("you_have_worked_today_for_x_hours") % TranslationServer.translate(PassedTime)}
				var Answer = yield(GlobalTime.ShowPopup(PopupData),"completed")
				match Answer:
					"NoBtn":
						return
					"YesBtn":
						GlobalSave.RemoveDayComplete(CurData)
						GlobalSave.AddDayOff(CurData)
						InitCurrentStatus()
						GlobalSave.emit_signal("UpdateToday")
			else:
				GlobalSave.RemoveDayComplete(CurData)
				GlobalSave.AddDayOff(CurData)
				InitCurrentStatus()
				GlobalSave.emit_signal("UpdateToday")
			#GlobalSave.AddDayOff(CurData)
		"Holiday":
			var GetToday = GlobalSave.GetTodayInfo()
			if GetToday != null && GetToday.has("check_in1"):
				var PassedTime = GlobalHebrew.HebrewTextConvert(GlobalTime.CalcAllTimePassed(),30)
				var PopupData = {"type": "YesNo","Title":"","Desc":TranslationServer.translate("you_have_worked_today_for_x_hours") % TranslationServer.translate(PassedTime)}
				var Answer = yield(GlobalTime.ShowPopup(PopupData),"completed")
				match Answer:
					"NoBtn":
						return
					"YesBtn":
						GlobalSave.RemoveDayComplete(CurData)
						GlobalSave.AddHoliday(CurData)
						InitCurrentStatus()
						GlobalSave.emit_signal("UpdateToday")
			else:
				GlobalSave.RemoveDayComplete(CurData)
				GlobalSave.AddHoliday(CurData)
				InitCurrentStatus()
				GlobalSave.emit_signal("UpdateToday")
		_:
			print(report, " not added yet.")
