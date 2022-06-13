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
	$CheckInData/HowLongWorked.text = ShowHowLongWorked(D)
	var SalorySettings = GlobalSave.GetValueFromSettingCategory("SaloryCalculation")
	$CheckInData/HowMuchEarned.visible = false
	if SalorySettings != null:
		if SalorySettings.has("enabled"):
			$CheckInData/HowMuchEarned.visible = SalorySettings["enabled"]
			var Salary = 1
			if SalorySettings.has("salary"):
				Salary = SalorySettings["salary"]
			
			$CheckInData/HowMuchEarned.text = "Earned "+GlobalTime.FloatToString(GlobalTime.DateToSeconds(D)/3600.0*Salary,2)
			if GlobalTime.CheckIfOnGoing(Info):
				$OnGoingTimer.start(1)
				
			if SalorySettings.has("sufix"):
				$CheckInData/HowMuchEarned.text = $CheckInData/HowMuchEarned.text+" "+SalorySettings["sufix"]

func UpdateDayInfo():
	if CurInfo.empty():
		return
	SetInfo(CurInfo)
	
func ShowHowLongWorked(Date):
	var LastWord = ""
	var Seconds = Date["hour"]*3600+Date["minute"]*60+Date["second"]
	if Seconds == 0:
		return ""
	if Seconds == 1:
		LastWord = "Second"
	elif Seconds < 60:
		LastWord = "Seconds"
	elif Seconds == 60:
		LastWord = "Minute"
	elif Seconds <3600:
		LastWord = "Minutes"
	elif Seconds == 3600:
		LastWord = "Hour"
	
	var Res = "Working Time "
	if Date["hour"]+Date["minute"] == 0:
		Res += String(Date["second"]) + " "+LastWord
	else:
		Res += String(Date["hour"])+":"+String(Date["minute"])+" "+LastWord
		
	return Res
 
func InitItemsInReport():
	for a in get_children():
		for b in a.get_children():
			if b is MenuButton:
				for c in b.get_children():
					c.connect("index_pressed",self,"SelectReport",[c])
		
func SelectReport(Index,Btn):
	var txt = Btn.get_item_text(Index)
	var Date = {}
	match txt:
		"Day Off":
			Date = {"year":GlobalTime.CurSelectedDate["year"],"month":GlobalTime.CurSelectedDate["month"],"day":GlobalTime.CurSelectedDate["day"]}
			GlobalSave.AddDayOff(Date)
		"Holiday":
			Date = {"year":GlobalTime.CurSelectedDate["year"],"month":GlobalTime.CurSelectedDate["month"],"day":GlobalTime.CurSelectedDate["day"]}
			GlobalSave.AddHoliday(Date)
		"Work Day":
			Date = {"year":GlobalTime.CurSelectedDate["year"],"month":GlobalTime.CurSelectedDate["month"],"day":GlobalTime.CurSelectedDate["day"]}
			GlobalSave.RemoveReport(Date)
		_:
			print(txt, " not added yet.")
	GlobalTime.emit_signal("UpdateDayInfo")


func _on_OnGoingTimer_timeout():
	UpdateDayInfo()
