extends Panel

var CurInfo = {}

func _ready():
	RemoveAllExcept("NoInfo")
# warning-ignore:return_value_discarded
	GlobalTime.connect("UpdateDayInfo",self,"UpdateDayInfo")
	InitItemsInReport()
	$CheckInData.visible = false
	$NoInfo.visible = true
	
func SetInfo(Info):
	CurInfo = Info
	$OnGoingTimer.stop()
	RemoveAllExcept("NoInfo")
	if CurInfo.has("report"):
		match CurInfo.report:
			"Day Off":
				InitDayOff(Info)
			"Holiday":
				InitHoliday(Info)
			_:
				InfoForCheckInData(Info)
	else:
		InfoForCheckInData(Info)
				
func RemoveAllExcept(ControlName):
	for x in get_children():
		if x is Control:
			if x.name == ControlName:
				x.visible = true
			else:
				x.visible = false
			
func InitDayOff(_Info):
	RemoveAllExcept("DayOffReport")
	$DayOffReport/Icon.texture = load("res://Assets/Icons/day.png")
	
func InitHoliday(_Info):
	RemoveAllExcept("HolidayReport")
	$HolidayReport/Icon.texture = load("res://Assets/Icons/holidays.png")
	
func InfoForCheckInData(Info):
	RemoveAllExcept("CheckInData")
	$CheckInData/WorkingHours.text = GlobalTime.GetAllCheckInAndOuts(Info)
	var D = GlobalTime.CalcHowLongWorked(Info)
	$CheckInData/HowLongWorked.text = TranslationServer.translate("Working Time").format(ShowHowLongWorked(D))
	var SalorySettings = GlobalSave.GetValueFromSettingCategory("SaloryCalculation")
	$CheckInData/HowMuchEarned.visible = false
	if GlobalTime.CheckIfOnGoing(Info):
		$CheckInData/EditWorkdays.visible = false
	else:
		$CheckInData/EditWorkdays.visible = true
	if SalorySettings != null:
		if SalorySettings.has("enabled"):
			$CheckInData/HowMuchEarned.visible = SalorySettings["enabled"]
			var Salary = 1
			if SalorySettings.has("salary"):
				Salary = SalorySettings["salary"]
			var sufix = ""
			if SalorySettings.has("sufix"):
				sufix = TranslationServer.translate(SalorySettings["sufix"])
				
			$CheckInData/HowMuchEarned.text = TranslationServer.translate("Earned").format([GlobalTime.FloatToString(GlobalTime.DateToSeconds(D)/3600.0*Salary,2),sufix])
			if GlobalTime.CheckIfOnGoing(Info):
				$OnGoingTimer.start(1)
				


func UpdateDayInfo():
	if CurInfo.empty():
		return
	SetInfo(CurInfo)
	
func ShowHowLongWorked(Date):
	var LastWord = ""
	var Seconds = Date["hour"]*3600+Date["minute"]*60+Date["second"]
	if Seconds == 0:
		return ""
	if Seconds < 60:
		LastWord = TranslationServer.translate("Seconds")
	elif Seconds <3600:
		LastWord = TranslationServer.translate("Minutes")
	elif Seconds == 3600:
		LastWord = TranslationServer.translate("Hour")
	
	var Res = ""
	if Date["hour"]+Date["minute"] == 0:
		Res += String(Date["second"])
	else:
		var Min = String(Date["minute"])
		if Min.length() == 1:
			Min = "0"+Min
		Res += String(Date["hour"])+":"+Min+" "
		
	return [Res,LastWord]
 
func InitItemsInReport():
	for a in get_children():
		for b in a.get_children():
			if b is MenuButton:
				for c in b.get_children():
					#c.set_item_metadata(c.get_current_index(),c.get_item_text())
					c.connect("index_pressed",self,"SelectReport",[c])
		
func SelectReport(Index,Btn):
	var txt = Btn.get_item_metadata(Index)
	var Date = {}
	match txt:
		"Day off":
			Date = {"year":GlobalTime.CurSelectedDate["year"],"month":GlobalTime.CurSelectedDate["month"],"day":GlobalTime.CurSelectedDate["day"]}
			GlobalSave.AddDayOff(Date)
		"Holiday":
			Date = {"year":GlobalTime.CurSelectedDate["year"],"month":GlobalTime.CurSelectedDate["month"],"day":GlobalTime.CurSelectedDate["day"]}
			GlobalSave.AddHoliday(Date)
		"Work day":
			Date = {"year":GlobalTime.CurSelectedDate["year"],"month":GlobalTime.CurSelectedDate["month"],"day":GlobalTime.CurSelectedDate["day"]}
			GlobalSave.RemoveReport(Date)
			var CheckInDate = Date.duplicate()
			
			CheckInDate["hour"] = 0
			CheckInDate["minute"] = 0
			CheckInDate["second"] = 0
			var CheckOutDate = CheckInDate.duplicate()
			GlobalSave.AddCheckIn(CheckInDate)
			var S = GlobalSave.GetValueFromSettingCategory("WorkingHours")
			if S == null:
				CheckOutDate["hour"] += 8
			else:
				CheckOutDate["hour"] += S["hours"]
			GlobalSave.AddCheckOut(CheckOutDate)
			GlobalTime.emit_signal("UpdateSpecificDayInfo",CheckOutDate["day"],GlobalSave.MySaves[CheckOutDate["year"]][CheckOutDate["month"]][CheckOutDate["day"]])
		"Edit working hours":
			Date = {"year":GlobalTime.CurSelectedDate["year"],"month":GlobalTime.CurSelectedDate["month"],"day":GlobalTime.CurSelectedDate["day"]}
			GlobalTime.HourSelectorUI.SyncDate(Date)
			GlobalTime.emit_signal("ShowOnlyScreen","HourEditorScreen")
		_:
			print(txt, " not added yet.")
	GlobalTime.emit_signal("UpdateDayInfo")


func _on_OnGoingTimer_timeout():
	UpdateDayInfo()
