extends Control

var HoldTween = null

func _ready():
	HoldTween = create_tween()
	HoldTween.connect("finished", Callable(self, "FinishedWaitTween"))
	GlobalSave.AddReportOptionsToNode($IdleOptions, true)
	GlobalSave.AddAditionalReportOptions($IdleOptions)
	$VBoxContainer/Control/StartStopBtn/TextureProgressBar.visible = false
	# warning-ignore:return_value_discarded
	GlobalTime.connect("InitSecond", Callable(self, "InitSecond"))
	# warning-ignore:return_value_discarded
	GlobalTime.connect("TimeModeChangedTo", Callable(self, "TimeModeChangedTo"))
	# warning-ignore:return_value_discarded
	GlobalSave.connect("UpdateToday", Callable(self, "UpdateToday"))
	# warning-ignore:return_value_discarded
	InitCurrentStatus()
	PopupForYesterday()
	PopupForSometimeAgo()
	$IdleOptions.get_popup().connect("index_pressed", Callable(self, "SelectedReport"))

func PopupForSometimeAgo():
	if GlobalTime.ForgotCheckInSometimeAgo == null:
		return
	var Date = str(GlobalTime.ForgotCheckInSometimeAgo["day"]) + "." + str(GlobalTime.ForgotCheckInSometimeAgo["month"]) + "." + str(GlobalTime.ForgotCheckInSometimeAgo["year"])
	var PopupData = {"type": "ForgetCheckOutSomeTimeAgo", "Desc": TranslationServer.translate("forgot_check_out_some_day") % Date}
	var Answer = await GlobalTime.ShowPopup(PopupData)
	match Answer:
		"EditBtn":
			GlobalTime.SelectCurDayList(GlobalTime.ForgotCheckInSometimeAgo, GlobalTime.ForgotCheckInSometimeAgo)
			var hour_editor = GlobalTime.LoadTool("Hour Editor")
			hour_editor.SyncDate(GlobalTime.ForgotCheckInSometimeAgo, "TimeScreen")
			GlobalTime.emit_signal("ShowOnlyScreen", "HourEditorScreen")
		"CloseBtn":
			pass
	GlobalTime.ForgotCheckInSometimeAgo = null

func PopupForYesterday():
	var CurDay = Time.get_datetime_dict_from_system()
	var Yesterday = GlobalTime.OffsetDay(CurDay, -1)
	if CurDay["month"] != Yesterday["month"] or CurDay["year"] != Yesterday["year"]:
		var _yest = GlobalSave.LoadSpecificFile(Yesterday["month"], Yesterday["year"], true)
	else:
		GlobalSave.AddMySavesPath(Yesterday)
	if not GlobalTime.ForgotCheckInYesterday:
		return
	var PopupData = {"type": "ForgetCheckOut"}
	var Answer = await GlobalTime.ShowPopup(PopupData)
	match Answer:
		"ContinueBtn":
			print("Pressed Continue")
			var CheckInDate = Time.get_datetime_dict_from_system()
			CheckInDate["hour"] = 0
			CheckInDate["minute"] = 0
			CheckInDate["second"] = 1
			GlobalTime.AddRetroTimeChange(GlobalTime.TIME_RETRO_CHECK_IN, CheckInDate)
		"CheckOutBtn":
			print("Pressed Checkout")
	GlobalTime.ForgotCheckInYesterday = false

func InitCurrentStatus(report_only = false):
	var CurDate = Time.get_datetime_dict_from_system()
	var CurDay = GlobalSave.LoadSpecificFile(CurDate["month"], CurDate["year"])
	var TotChecks = 0
	var CurCheck = 1
	$VBoxContainer/HolidayToday.visible = false
	if CurDay != null:
		for x in CurDay:
			if x == CurDate["day"]:
				if CurDay[x].has("report"):
					$VBoxContainer/HolidayToday.visible = true
					ShowDayOff(CurDay[x]["report"])
				else:
					while CurDay[x].has("check_in" + str(CurCheck)):
						TotChecks += 1
						if not report_only:
							GlobalTime.AddRetroTimeChange(GlobalTime.TIME_CHECKED_IN, CurDay[x]["check_in" + str(CurCheck)])
						if CurDay[x].has("check_out" + str(CurCheck)):
							if not report_only:
								GlobalTime.AddRetroTimeChange(GlobalTime.TIME_PAUSED, CurDay[x]["check_out" + str(CurCheck)])
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

func TimeModeChangedTo(ToMode):
	match ToMode:
		GlobalTime.TIME_IDLE:
			$VBoxContainer/Control/StartStopBtn.ForceToggle(false)
			$VBoxContainer/CheckedInText.text = ""
			$VBoxContainer/PassedTime.text = ""
			SyncNosafot()
		GlobalTime.TIME_CHECKED_IN:
			$VBoxContainer/CheckedInText.text = TranslationServer.translate("check_in_info") % str(GlobalTime.ShowLastCheckIn())
			$VBoxContainer/Control/StartStopBtn.ForceToggle(true)
			InitSecond()
		GlobalTime.TIME_PAUSED:
			$VBoxContainer/Control/StartStopBtn.ForceToggle(false)
			var StartedWorking = GlobalTime.GetLastCheckIn()
			var EndedWorking = GlobalTime.GetLastCheckOut()
			var PassedTime = GlobalTime.CalcAllCheckInsAndOutsToSeconds()
			$VBoxContainer/PassedTime.text = TranslationServer.translate("worked_today_info") % str(GlobalTime.TimeToString(PassedTime))
			var In_Min = str(StartedWorking["minute"])
			var Out_Min = str(EndedWorking["minute"])
			if In_Min.length() == 1:
				In_Min = "0" + In_Min
			if Out_Min.length() == 1:
				Out_Min = "0" + Out_Min
			$VBoxContainer/CheckedInText.text = TranslationServer.translate("checked_out_info") % [str(StartedWorking["hour"]) + ":" + In_Min + " -> " + str(EndedWorking["hour"]) + ":" + Out_Min]
			SyncNosafot()

func _on_CheckinBtn_pressed():
	GlobalTime.ChangeTimeModes(GlobalTime.TIME_CHECKED_IN)

func SyncNosafot():
	var Nosafot = GlobalSave.GetValueFromSettingCategory("SalaryDeduction")
	var WorkHours = GlobalSave.GetValueFromSettingCategory("WorkingHours")
	var has_125 = false
	var has_150 = false
	if Nosafot != null and WorkHours != null:
		if Nosafot.has("overtime125"):
			has_125 = Nosafot["overtime125"]
		if Nosafot.has("overtime150"):
			has_150 = Nosafot["overtime150"]
	var PassedTime = GlobalTime.CalcAllCheckInsAndOutsToSeconds()
	$VBoxContainer/Nosafot150Info.text = ""
	var Worked125 = 0
	var Worked150 = 0
	if has_125:
		if PassedTime > WorkHours["hours"] * 3600:
			Worked125 = PassedTime - (WorkHours["hours"] * 3600)
			if Worked125 > 2 * 3600:
				Worked125 = 2 * 3600
	if has_150:
		if PassedTime > (WorkHours["hours"] + 2) * 3600:
			Worked150 = PassedTime - ((WorkHours["hours"] + 2) * 3600)
	if Worked125 == 0:
		if $VBoxContainer/Nosafot125Info.visible:
			$VBoxContainer/Nosafot125Info.visible = false
		$VBoxContainer/Nosafot125Info.text = ""
	else:
		if not $VBoxContainer/Nosafot125Info.visible:
			$VBoxContainer/Nosafot125Info.visible = true
		$VBoxContainer/Nosafot125Info.text = TranslationServer.translate("Overtime 125").format([GlobalTime.TimeToString(Worked125)])
	if Worked150 == 0:
		if $VBoxContainer/Nosafot150Info.visible:
			$VBoxContainer/Nosafot150Info.visible = false
		$VBoxContainer/Nosafot150Info.text = ""
	else:
		if not $VBoxContainer/Nosafot150Info.visible:
			$VBoxContainer/Nosafot150Info.visible = true
		$VBoxContainer/Nosafot150Info.text = TranslationServer.translate("Overtime 150").format([GlobalTime.TimeToString(Worked150)])

func InitSecond():
	if GlobalTime.CurTimeMode != GlobalTime.TIME_CHECKED_IN:
		return
	var CurDate = GlobalTime.CalcAllTimePassed()
	$VBoxContainer/PassedTime.text = TranslationServer.translate("passed_time_info") % str(CurDate)
	SyncNosafot()

func _on_PauseBtn_pressed():
	GlobalTime.ChangeTimeModes(GlobalTime.TIME_PAUSED)

func _on_ResumeBtn_pressed():
	GlobalTime.ChangeTimeModes(GlobalTime.TIME_CHECKED_IN)

func _on_CheckOutBtn_pressed():
	GlobalTime.ChangeTimeModes(GlobalTime.TIME_PAUSED)

func _on_StartStopBtn_Toggled():
	if $VBoxContainer/Control/StartStopBtn.is_Toggled:
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
		var PopupData = {"type": "YesNo", "Title": "", "Desc": TranslationServer.translate("are_you_sure_to_skip") % GlobalHebrew.HebrewTextConvert(TranslationServer.translate(TodayReport), 30)}
		$VBoxContainer/Control/StartStopBtn.DontFlip = true
		var Answer = await GlobalTime.ShowPopup(PopupData)
		match Answer:
			"NoBtn":
				pass
			"YesBtn":
				var Date = Time.get_datetime_dict_from_system()
				GlobalSave.RemoveReport(Date)
				GlobalSave.emit_signal("UpdateToday")
				$VBoxContainer/Control/StartStopBtn.BtnPressed()

func _on_StartStopBtn_button_down():
	if $VBoxContainer/Control/StartStopBtn.is_Toggled:
		return
	HoldTween.kill()  # Stop any ongoing tweens
	$VBoxContainer/Control/StartStopBtn/TextureProgressBar.value = 0
	$VBoxContainer/Control/StartStopBtn/TextureProgressBar.visible = true
	HoldTween = create_tween()
	HoldTween.tween_property($VBoxContainer/Control/StartStopBtn/TextureProgressBar, "value", 100, 0.8).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)

func _on_StartStopBtn_button_up():
	$VBoxContainer/Control/StartStopBtn/TextureProgressBar.visible = false

func FinishedWaitTween():
	$VBoxContainer/Control/StartStopBtn.DontFlip = true
	$IdleOptions.ForceShowOnMouse(get_global_mouse_position())

func SelectedReport(index):
	var report = $IdleOptions.get_popup().get_item_metadata(index)
	var CurData = Time.get_datetime_dict_from_system()
	GlobalTime.SelectCurDayList(CurData, CurData)
	match report:
		"Forgot Check-in?":
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
			GlobalTime.FillCheckInOutArray(CheckInDate, CheckOutDate)
			GlobalTime.emit_signal("UpdateSpecificDayInfo", CheckOutDate["day"], GlobalSave.MySaves[CheckOutDate["year"]][CheckOutDate["month"]][CheckOutDate["day"]])
			GlobalTime.SyncCurDay(CheckOutDate)
			var hourUI = GlobalTime.LoadTool("Hour Editor")
			hourUI.SyncDate(CurData, "TimeScreen")
			GlobalTime.emit_signal("ShowOnlyScreen", "HourEditorScreen")
		"Day off":
			var GetToday = GlobalSave.GetTodayInfo()
			if GetToday != null and GetToday.has("check_in1"):
				var PassedTime = GlobalHebrew.HebrewTextConvert(GlobalTime.CalcAllTimePassed(), 30)
				var PopupData = {"type": "YesNo", "Title": "", "Desc": TranslationServer.translate("you_have_worked_today_for_x_hours") % TranslationServer.translate(PassedTime)}
				var Answer = await GlobalTime.ShowPopup(PopupData)
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
		"Holiday":
			var GetToday = GlobalSave.GetTodayInfo()
			if GetToday != null and GetToday.has("check_in1"):
				var PassedTime = GlobalHebrew.HebrewTextConvert(GlobalTime.CalcAllTimePassed(), 30)
				var PopupData = {"type": "YesNo", "Title": "", "Desc": TranslationServer.translate("you_have_worked_today_for_x_hours") % TranslationServer.translate(PassedTime)}
				var Answer = await GlobalTime.ShowPopup(PopupData)
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
			print_debug(report, " not added yet.")
