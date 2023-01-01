extends Panel

var CurInfo = {}

var MultiSelectedInfo = []
signal FinishedReport()

func _ready():
	
# warning-ignore:return_value_discarded
	GlobalTime.connect("UpdateDayInfo",self,"UpdateDayInfo")
	$CheckInData.visible = false
	$NoInfo.visible = true
	RemoveAllExcept("NoInfo")
	GlobalSave.AddReportOptionsToNode($NoInfo/Report)
	
	$NoInfo/Report.get_popup().connect("index_pressed",self,"SelectReport",[$NoInfo/Report])
	$MultiSelect/Report.get_popup().connect("index_pressed",self,"SelectReport",[$MultiSelect/Report,true])
	
	
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
				for a in x.get_children():
					if a is MenuButton:
						a.get_popup().clear()
			else:
				x.visible = false
			
func InitDayOff(_Info):
	RemoveAllExcept("DayOffReport")
	GlobalSave.AddReportOptionsToNode($DayOffReport/Report)
	if !$DayOffReport/Report.get_popup().is_connected("index_pressed",self,"SelectReport"):
		$DayOffReport/Report.get_popup().connect("index_pressed",self,"SelectReport",[$DayOffReport/Report])
	$DayOffReport/Icon.texture = load("res://Assets/Icons/day.png")
	
func InitHoliday(_Info):
	RemoveAllExcept("HolidayReport")
	GlobalSave.AddReportOptionsToNode($HolidayReport/Report)
	if !$HolidayReport/Report.get_popup().is_connected("index_pressed",self,"SelectReport"):
		$HolidayReport/Report.get_popup().connect("index_pressed",self,"SelectReport",[$HolidayReport/Report])
	$HolidayReport/Icon.texture = load("res://Assets/Icons/holidays.png")
	
func ReleaseAllSelected():
	if MultiSelectedInfo == []:
		return
	for x in MultiSelectedInfo:
		x.AnimateSelected(false)
	MultiSelectedInfo.clear()
	
func MultiSelect(Info):
	RemoveAllExcept("MultiSelect")
	GlobalSave.AddReportOptionsToNode($MultiSelect/Report)

	if Info == null:
		$MultiSelect/HBoxContainer/DayNum.text = "0"
	else:
		if MultiSelectedInfo.has(Info):
			Info.AnimateSelected(false)
			MultiSelectedInfo.erase(Info)
		else:
			if Info.CurDayInfo.empty():
				MultiSelectedInfo.append(Info)
				Info.AnimateSelected(true)
			else:
				Info.AnimateCantSelect()
	if MultiSelectedInfo.size()==1:
		$MultiSelect/Report.visible = false
	else:
		$MultiSelect/Report.visible = true
		
	$MultiSelect/HBoxContainer/DayNum.text = String(MultiSelectedInfo.size())
		
	
func InfoForCheckInData(Info):
	#check if in debug mode
	#if OS.is_debug_build():
	#	$CheckInData/EditWorkdays.get_popup().add_item("Remove Check Out")
	
	Info = GlobalTime.FilterChecksIns(Info)
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
		GlobalSave.AddCustomListOptionsToNode($CheckInData/EditWorkdays,["Edit working hours"])
		if !$CheckInData/EditWorkdays.get_popup().is_connected("index_pressed",self,"SelectReport"):
			$CheckInData/EditWorkdays.get_popup().connect("index_pressed",self,"SelectReport",[$CheckInData/EditWorkdays])
	
	if SalorySettings != null:
		if SalorySettings.has("enabled"):
			$CheckInData/HowMuchEarned.visible = SalorySettings["enabled"]
			var sufix = ""
			if SalorySettings.has("sufix"):
				sufix = TranslationServer.translate(SalorySettings["sufix"])
			var WithNosafot = GlobalTime.GetHowManySecondsOnNosafot(GlobalTime.DateToSeconds(D))
			var has_nosafot_rate = ""
			if WithNosafot[2] > 0:
				has_nosafot_rate = "rate 150%"
			elif WithNosafot[1] > 0:
				has_nosafot_rate = "rate 125%"
			$CheckInData/HowMuchEarned.text = TranslationServer.translate("Earned").format([GlobalTime.FloatToString(((WithNosafot[0]/3600.0*SalorySettings["salary"])+(WithNosafot[1]/3600.0*SalorySettings["salary"])*1.25+(WithNosafot[2]/3600.0*SalorySettings["salary"])*1.5),2),sufix,TranslationServer.translate(has_nosafot_rate)])
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
		return ["0",TranslationServer.translate("Seconds")]
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
 
		
func SelectReport(Index,Btn,multi_select = false):
	if multi_select:
		
		for x in MultiSelectedInfo:
			GlobalTime.CurSelectedDate["day"] = int(x.text)
			SelectReport(Index,Btn,false)
			
		GlobalTime.emit_signal("MultiSelect",false)
		return
	var txt = Btn.get_popup().get_item_metadata(Index)
	var Date = {}
	match txt:
		"Remove Check Out":
			var LastCheckOut = GlobalSave.FindLastCheckIn(GlobalTime.CurSelectedDate["info"])
			Date = {"year":GlobalTime.CurSelectedDate["year"],"month":GlobalTime.CurSelectedDate["month"],"day":GlobalTime.CurSelectedDate["day"]}
			GlobalSave.RemoveCheckOut(LastCheckOut,Date)
			
		"Day off":
			Date = {"year":GlobalTime.CurSelectedDate["year"],"month":GlobalTime.CurSelectedDate["month"],"day":GlobalTime.CurSelectedDate["day"]}
			GlobalSave.AddDayOff(Date)
			GlobalTime.emit_signal("UpdateSpecificDayInfo",GlobalTime.CurSelectedDate["day"],GlobalSave.MySaves[GlobalTime.CurSelectedDate["year"]][GlobalTime.CurSelectedDate["month"]][GlobalTime.CurSelectedDate["day"]])
			GlobalTime.SyncCurDay(Date)
		"Holiday":
			Date = {"year":GlobalTime.CurSelectedDate["year"],"month":GlobalTime.CurSelectedDate["month"],"day":GlobalTime.CurSelectedDate["day"]}
			GlobalSave.AddHoliday(Date)
			GlobalTime.emit_signal("UpdateSpecificDayInfo",GlobalTime.CurSelectedDate["day"],GlobalSave.MySaves[GlobalTime.CurSelectedDate["year"]][GlobalTime.CurSelectedDate["month"]][GlobalTime.CurSelectedDate["day"]])
			GlobalTime.SyncCurDay(Date)
		"Work day":
			Date = {"year":GlobalTime.CurSelectedDate["year"],"month":GlobalTime.CurSelectedDate["month"],"day":GlobalTime.CurSelectedDate["day"]}
			GlobalSave.RemoveDayComplete(Date)
			#GlobalSave.RemoveReport(Date)
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
				if S.has("minutes"):
					CheckOutDate["minute"] = S["minutes"]
			GlobalSave.AddCheckOut(CheckOutDate)
			GlobalTime.FillCheckInOutArray(CheckInDate,CheckOutDate)
			GlobalTime.emit_signal("UpdateSpecificDayInfo",CheckOutDate["day"],GlobalSave.MySaves[CheckOutDate["year"]][CheckOutDate["month"]][CheckOutDate["day"]])
			GlobalTime.SyncCurDay(CheckOutDate)
		"Edit working hours":
			Date = {"year":GlobalTime.CurSelectedDate["year"],"month":GlobalTime.CurSelectedDate["month"],"day":GlobalTime.CurSelectedDate["day"]}
			var hourUI = GlobalTime.LoadTool("Hour Editor")
			hourUI.SyncDate(Date)
			GlobalTime.emit_signal("ShowOnlyScreen","HourEditorScreen")
		"Check In":
			#This is in debug mode only (Windows) will add only check in without check out
			Date = {"year":GlobalTime.CurSelectedDate["year"],"month":GlobalTime.CurSelectedDate["month"],"day":GlobalTime.CurSelectedDate["day"]}
			
			Date["hour"] = 12
			Date["minute"] = 0
			Date["second"] = 0
			GlobalSave.AddCheckIn(Date)
			GlobalTime.emit_signal("UpdateSpecificDayInfo",Date["day"],GlobalSave.MySaves[Date["year"]][Date["month"]][Date["day"]])
		_:
			print(txt, " not added yet.")
	GlobalTime.emit_signal("UpdateDayInfo")
	emit_signal("FinishedReport")


func _on_OnGoingTimer_timeout():
	UpdateDayInfo()


