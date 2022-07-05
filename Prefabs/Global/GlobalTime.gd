extends Control

const TIME_IDLE = "IDLE"
const TIME_CHECKED_IN = "CHECKED_IN"
const TIME_PAUSED = "PAUSED"
const TIME_RETRO_CHECK_IN = "RETRO_CHECK_IN"
var CurTimeMode = TIME_IDLE

var SecondTimer = null
var OldTime = null

var HasCheckin = []
var HasCheckOut = []

var DateDB = {}

var CurSelectedDate = {"day": 0,"month":0,"year":0}
var TempCurMonth = 0
var TempCurYear = 0
var HourSelectorUI = null
var ForgotCheckInYesterday = false

signal InitSecond()
signal TimeModeChangedTo(TimeMode)
# warning-ignore:unused_signal
signal SelectDay(DayNode)
signal BtnGroupPressed(BtnNode,GroupName)
# warning-ignore:unused_signal
signal UpdateDayInfo()
# warning-ignore:unused_signal
signal UpdateSpecificDayInfo(DayNumber,DayInfoData)
# warning-ignore:unused_signal
signal ShowOnlyScreen(ScreenName)
# warning-ignore:unused_signal
signal ReloadCurrentDate()


func _ready():
	InitSecondTimer()
	InitDates()
	
func InitDates():
	AddDateDB(1,31,5,2022)
	AddDateDB(4,30,6,2022)
	AddDateDB(6,31,7,2022)

func SelectCurDate(DayNode,DayInfo):
	CurSelectedDate["day"] = int(DayNode.text)
	CurSelectedDate["year"] = TempCurYear
	CurSelectedDate["month"] = TempCurMonth
	CurSelectedDate["info"] = DayInfo
	emit_signal("SelectDay",DayNode)
	
func HasPrevMonth(Month,Year):
	Month -= 1
	if Month <= 0:
		Year -= 1
		Month = 12
	if !DateDB.has(Year):
		return null
	if !DateDB[Year].has(Month):
		return null
	return DateDB[Year][Month]
	
func HasNextMonth(Month,Year):
	Month += 1
	if Month > 12:
		Year += 1
		Month = 1
	if !DateDB.has(Year):
		return null
	if !DateDB[Year].has(Month):
		return null
	return DateDB[Year][Month]
	
func DisplayFullDate(Date):
	var DayName = String(Date["day"])
	var MonthName = GetMonthName(Date["month"])[1]
	var YearName = String(Date["year"])
	return DayName+", "+MonthName+" "+YearName
	
func HasNextYear(Month,Year):
	Year += 1
	if !DateDB.has(Year):
		return null
	if !DateDB[Year].has(Month):
		return null
	return DateDB[Year][Month]
	
func HasPrevYear(Month,Year):
	Year -= 1
	if !DateDB.has(Year):
		return null
	if !DateDB[Year].has(Month):
		return null
	return DateDB[Year][Month]

func GetDateInfo(Month,Year):
	return DateDB[Year][Month]

func AddDateDB(StartsFrom,TotDays,Month,Year):
	if !DateDB.has(Year):
		DateDB[Year] = {}
		
	if !DateDB[Year].has(Month):
		DateDB[Year][Month] = {"tot_days":TotDays,"start_from":StartsFrom}
	
func InitSecondTimer():
	OldTime = OS.get_datetime()
	SecondTimer = Timer.new()
	add_child(SecondTimer)
	#SecondTimer.one_shot = false
	SecondTimer.connect("timeout",self,"timeout")
	SecondTimer.start(-1)
	
func timeout():
	OldTime = OS.get_datetime()
	emit_signal("InitSecond")
	
func AddRetroTimeChange(ToTimeMode,CurInfo):
	CurTimeMode = ToTimeMode
	match CurTimeMode:
		TIME_CHECKED_IN:
			HasCheckin.append(CurInfo)
		TIME_PAUSED:
			HasCheckOut.append(CurInfo)
		TIME_RETRO_CHECK_IN:
			HasCheckin.append(CurInfo)
			GlobalSave.AddCheckIn(CurInfo)
			CurTimeMode = TIME_CHECKED_IN
			emit_signal("TimeModeChangedTo",CurTimeMode)
			return
	emit_signal("TimeModeChangedTo",ToTimeMode)
	
func ChangeTimeModes(ToTimeMode):
	CurTimeMode = ToTimeMode
	#ToMode
	match CurTimeMode:
		TIME_CHECKED_IN:
			HasCheckin.append(OS.get_datetime())
			GlobalSave.AddCheckIn(OS.get_datetime())
		TIME_PAUSED:
			HasCheckOut.append(OS.get_datetime())
			GlobalSave.AddCheckOut(OS.get_datetime())
			
	emit_signal("TimeModeChangedTo",ToTimeMode)

func TimeTo2DigitStr(Time):
	var t = String(Time)
	if t.length() == 1:
		t = "0"+t
	return t
func GetAllCheckInAndOuts(Info):
	var Res = ""
	var Times = 1
	var TotChecks = 0
	var SelectedDay = {}
	for x in Info:
		if "check_in" in x:
			TotChecks += 1
			SelectedDay = Info[x]
			if Times == 1:
				Res = Res + TimeTo2DigitStr(Info[x]["hour"])+":"+TimeTo2DigitStr(Info[x]["minute"])
			elif Times == 2:
				Res = Res+", " + TimeTo2DigitStr(Info[x]["hour"])+":"+TimeTo2DigitStr(Info[x]["minute"])
			else:
				Res = String(Times) +" "+TranslationServer.translate("Checkins")+", "+TimeTo2DigitStr(Info[x]["hour"])+":"+TimeTo2DigitStr(Info[x]["minute"])
		if "check_out" in x:
			TotChecks -= 1
			Res = Res +" - "+TimeTo2DigitStr(Info[x]["hour"])+":"+TimeTo2DigitStr(Info[x]["minute"])
			Times+= 1
	var CurDay = OS.get_datetime()
	if TotChecks == 1:
		if SelectedDay["day"] == CurDay["day"] && SelectedDay["month"] == CurDay["month"] && SelectedDay["year"] == CurDay["year"]:
			Res = Res +" - "+TranslationServer.translate("On_Going")
	return Res

func OffsetDay(CurDay,Offset_Day):
	CurDay["day"] += Offset_Day
	#Check backward
	if CurDay["day"] <= 0:
		CurDay["month"] -= 1
		if CurDay["month"] <= 0:
			CurDay["year"] -= 1
			CurDay["month"] = 12
		CurDay["day"] = DateDB[CurDay["year"]][CurDay["month"]]["tot_days"]-CurDay["day"]
	return CurDay
	
func CheckIfOnGoing(Info):
	var TotChecks = 0
	for x in Info:
		if "check_in" in x:
			TotChecks += 1
		if "check_out" in x:
			TotChecks -= 1
	if TotChecks>0:
		return true
	return false
	
func CalcBetweenCheckinsTOSeconds(Info):
	var Num = 1
	var SecondsWorked = 0
	var TotSeconds = 0
	while Info.has("check_in"+String(Num)):
		SecondsWorked += Info["check_in"+String(Num)]["hour"]*3600+Info["check_in"+String(Num)]["minute"]*60+Info["check_in"+String(Num)]["second"]
		if Info.has("check_out"+String(Num)):
			SecondsWorked = (Info["check_out"+String(Num)]["hour"]*3600+Info["check_out"+String(Num)]["minute"]*60+Info["check_out"+String(Num)]["second"])-SecondsWorked
			TotSeconds += SecondsWorked
			SecondsWorked = 0
		Num += 1
	return TotSeconds
	
func CalcHowLongWorked(Info):
	var SecondsWorked = 0
	var TotSeconds = 0
	var Num = 1
	var LastCheckIn = {}
	while Info.has("check_in"+String(Num)):
		SecondsWorked += Info["check_in"+String(Num)]["hour"]*3600+Info["check_in"+String(Num)]["minute"]*60+Info["check_in"+String(Num)]["second"]
		LastCheckIn = Info["check_in"+String(Num)]
		if Info.has("check_out"+String(Num)):
			SecondsWorked = (Info["check_out"+String(Num)]["hour"]*3600+Info["check_out"+String(Num)]["minute"]*60+Info["check_out"+String(Num)]["second"])-SecondsWorked
			TotSeconds += SecondsWorked
			SecondsWorked = 0
		Num += 1
	var CurDate = OS.get_datetime()
	var AddInSeconds = 0
	if LastCheckIn.has("year") && CurTimeMode == TIME_CHECKED_IN:
		if CurDate["year"] == LastCheckIn["year"] && CurDate["month"] == LastCheckIn["month"] && CurDate["day"] == LastCheckIn["day"]:
			AddInSeconds = (CurDate["hour"] - LastCheckIn["hour"])*3600
			AddInSeconds += (CurDate["minute"] - LastCheckIn["minute"])*60
			AddInSeconds += (CurDate["second"] - LastCheckIn["second"])
	var Date = SecondsToDate(TotSeconds+AddInSeconds)
	return Date
	

func FloatToString(FloatNum,Nums):
	#Seperating float <Num>.<Num>
	var Sides = String(FloatNum).split(".")
	if Sides.size()==2:
		if Sides[1].length() == 1:
			Sides[1] = Sides[1]+"0"
		else:
			Sides[1] = Sides[1].substr(0,Nums)
			
	var a = Sides[0].length()
	var count = 0
	var r = ""
	while true:
		a -= 1
		r = Sides[0][a] + r
		
		count += 1
		if count == 3 && a != 0:
			r = ","+r
			count = 0
			
		if a == 0:
			break
	var NewRet = r
	if Sides.size()==2:
		NewRet += "."+Sides[1]
	
	return NewRet
	
	
func ShowTime():
	var Min = String(OldTime["minute"])
	if Min.length() == 1:
		Min = "0"+Min
	return String(OldTime["hour"])+":"+Min
	
func ShowLastCheckIn():
	var T = GetLastCheckIn()
	var Min = String(T["minute"])
	if Min.length() == 1:
		Min = "0"+Min
	return String(T["hour"])+":"+Min
	
	
func GetLastCheckIn():
	return GlobalTime.HasCheckin[GlobalTime.HasCheckin.size()-1]
	
func GetLastCheckOut():
	return GlobalTime.HasCheckOut[GlobalTime.HasCheckOut.size()-1]
	
func CalcAllTimePassed():
	var Seconds = 0
	if HasCheckOut != []:
		for x in range(HasCheckOut.size()):
			Seconds += HasCheckOut[x]["second"]-HasCheckin[x]["second"]
			Seconds += (HasCheckOut[x]["minute"]-HasCheckin[x]["minute"])*60
			Seconds += (HasCheckOut[x]["hour"]-HasCheckin[x]["hour"])*3600
			Seconds += (HasCheckOut[x]["day"]-HasCheckin[x]["day"])*86400
	
	var CurTime = OS.get_datetime()
	if CurTimeMode == TIME_PAUSED:
		CurTime = GetLastCheckOut()
	return CalcTimePassed(GetLastCheckIn(),CurTime,Seconds)
	
func CalcAllCheckInsAndOutsToSeconds():
	var Seconds = 0
	if HasCheckOut != []:
		for x in range(HasCheckOut.size()):
			Seconds += HasCheckOut[x]["second"]-HasCheckin[x]["second"]
			Seconds += (HasCheckOut[x]["minute"]-HasCheckin[x]["minute"])*60
			Seconds += (HasCheckOut[x]["hour"]-HasCheckin[x]["hour"])*3600
			Seconds += (HasCheckOut[x]["day"]-HasCheckin[x]["day"])*86400
			if x == HasCheckOut.size()-1:
				if HasCheckin.size() > HasCheckOut.size():
					var CurDate = OS.get_datetime()
					Seconds += CurDate["second"]-HasCheckin[x+1]["second"]
					Seconds += (CurDate["minute"]-HasCheckin[x+1]["minute"])*60
					Seconds += (CurDate["hour"]-HasCheckin[x+1]["hour"])*3600
					Seconds += (CurDate["day"]-HasCheckin[x+1]["day"])*86400
	else:
		if HasCheckin.size() > HasCheckOut.size():
			var CurDate = OS.get_datetime()
			Seconds += CurDate["second"]-HasCheckin[0]["second"]
			Seconds += (CurDate["minute"]-HasCheckin[0]["minute"])*60
			Seconds += (CurDate["hour"]-HasCheckin[0]["hour"])*3600
			Seconds += (CurDate["day"]-HasCheckin[0]["day"])*86400
	return Seconds
	
func TimeToString(Seconds):
	var Date = SecondsToDate(Seconds)
	
	if Date["day"]>0:
		var res = TranslationServer.translate("days_and_hours").format([String(Date["day"]),String(Date["hour"])])
		return res
	if Date["hour"]>0:
		var res = TranslationServer.translate("hours_and_minutes").format([String(Date["hour"]),String(Date["minute"])])
		return res
	if Date["minute"]>0:
		var res = TranslationServer.translate("minutes_and_seconds").format([String(Date["minute"]),String(Date["second"])])
		return res
	return TranslationServer.translate("second_info") % String(Date["second"])
	
	

	
func CalcTimePassed(FromTime,ToTime,PlusSeconds = 0):
	var FromSeconds = DateToSeconds(FromTime)
	var ToSeconds = DateToSeconds(ToTime)
	
	var SecondsPassed = ToSeconds - FromSeconds
	var Date = SecondsToDate(SecondsPassed+PlusSeconds)
	
	var Res = ""
	if Date["day"]>0:
		Res += String(Date["day"])+":"
	if Date["hour"]>0:
		Res += String(Date["hour"])+":"
		
	var Min = String(Date["minute"])
	if Min.length() == 1:
		Min = "0"+Min
		
	if Date["minute"]>0:
		Res += Min+":"
	
	var Sec = String(Date["second"])
	if Sec.length() == 1:
		Sec = "0"+Sec
	Res += Sec
	if Date["minute"] == 0 && Date["hour"] == 0:
		Res += " "+TranslationServer.translate("Seconds")
	return Res
	
func SecondsToDate(Seconds):
	var Date = {"second":0,"minute":0,"hour":0,"day":0}
	
	#Calc Day
	while Seconds >= 86400:
		if Seconds < 86400:
			break
		Date["day"] += 1
		Seconds -= 86400
	
	#Calc Hour
	while Seconds >= 3600:
		if Seconds < 3600:
			break
		Date["hour"] += 1
		Seconds -= 3600
		
	#Calc Minute
	while Seconds >= 60:
		if Seconds < 60:
			break
		Date["minute"] += 1
		Seconds -= 60
	
	Date["second"] = Seconds
	return Date
	
func ShowDate():
	return WeekDayToDayName(OldTime["weekday"])[1]+", "+GetMonthName(OldTime["month"])[0]+" "+String(OldTime["day"])+", "+String(OldTime["year"])
	
func ShowSeconds():
	var Sec = String(OldTime["second"])
	if Sec.length() == 1:
		Sec = "0"+Sec
	return String(Sec)
	
func DateToSeconds(Date):
	var Res = 0
	if Date.has("day"):
		Res += Date["day"]*86400
	if Date.has("hour"):
		Res += Date["hour"]*3600
	if Date.has("minute"):
		Res += Date["minute"]*60
	if Date.has("second"):
		Res += Date["second"]
	return Res

func IsraelIncomeCalcFromSalary(SecondsWorked,Sec125,Sec150):
	var Salary = GlobalSave.GetValueFromSettingCategory("SaloryCalculation")
	if Salary == null:
		return {"no_info_on_salary":""}
	var GrossSalary = (SecondsWorked/3600 * Salary["salary"]) + (Sec125/3600.0 * Salary["salary"] * 1.25) + (Sec150/3600.0 * Salary["salary"] * 1.50)+Salary["bonus"]
	
	#GrossSalary =  13480+4137.3
	var Credit = 2.25
	var CreditAmount = 223
	var TaxMore = 50.0
	var AvarageSalary = 6331
	var TaxInfo = [[6450, 10.0],[9240, 14.0],[14840, 20.0],[20620, 31.0], [42910,35.0], [55270,47.0]]
	
	var S = GlobalSave.GetValueFromSettingCategory("SalaryDeduction")
	var sufix = ""
	if Salary.has("sufix"):
		sufix = Salary["sufix"]
	if S.has("credit"):
		Credit = S["credit"]
		
	
	#Tax should be 2295.95
	#TaxInfo
	
	
	#Gross, Income tax, Social security, Health tax, Net
	var Rest = {"Gross": FloatToString(GrossSalary,2)+sufix}
	if Sec125 > 0:
		Rest["NosafotHours 125%"] = FloatToString(Sec125/3600.0,1)+" "+TranslationServer.translate("hours")
		Rest["NosafotEarned 125%"] = FloatToString(Sec125/3600.0*Salary["salary"] * 1.25,2)+sufix
	if Sec150 > 0:
		Rest["NosafotHours 150%"] = FloatToString(Sec150/3600.0,1)+" "+TranslationServer.translate("hours")
		Rest["NosafotEarned 150%"] = FloatToString(Sec150/3600.0*Salary["salary"] * 1.50,2)+sufix
	var NetList = []
	if GrossSalary <= TaxInfo[0][0]:
		Rest["Income-tax"] = (GrossSalary * TaxInfo[0][1]) / 100.0
	else:
		var LastValue = 0
		for Tax in TaxInfo:
			if GrossSalary >= Tax[0]:
				var T = ((Tax[0]-LastValue) * Tax[1]) / 100.0
				NetList.append(T)
				LastValue = Tax[0]
			else:
				var T = ((GrossSalary - LastValue) * Tax[1]) / 100.0
				NetList.append(T)
				break
		if GrossSalary > TaxInfo[TaxInfo.size()-1][0]:
			var T = ((GrossSalary - LastValue) * TaxMore) / 100.0
			NetList.append(T)
		var Tax = 0
		
		for x in NetList:
			Tax += x
		Rest["Income-tax"] = Tax
	
	if Rest["Income-tax"] > (Credit * CreditAmount):
		Rest["Income-tax"] -= (Credit * CreditAmount)
		
	
	#Calc Health Tax Security
	Rest["Social-security"] = 0
	Rest["Health-tax"] = 0
	
	if GrossSalary <= AvarageSalary:
		Rest["Health-tax"] = (GrossSalary) * 3.1 / 100
	else:
		Rest["Health-tax"] = (AvarageSalary) * 3.1 / 100
		Rest["Health-tax"] += (GrossSalary - AvarageSalary) * 5 / 100
		
		
	if GrossSalary <= AvarageSalary:
		Rest["Social-security"] = (GrossSalary) * 0.4 / 100
	else:
		Rest["Social-security"] = (AvarageSalary) * 0.4 / 100
		Rest["Social-security"] += (GrossSalary - AvarageSalary) * 7 / 100
		
	Rest["Net"] = GrossSalary - Rest["Social-security"] - Rest["Health-tax"]-Rest["Income-tax"]
	
	Rest["Health-tax"] = FloatToString(Rest["Health-tax"],2)+sufix
	Rest["Social-security"] = FloatToString(Rest["Social-security"],2)+sufix
	Rest["Income-tax"] = FloatToString(Rest["Income-tax"],2)+sufix
	Rest["Net"] = FloatToString(Rest["Net"],2)+sufix
	return Rest
	
func GetHowManySecondsOnNosafot(TotalDailySeconds):
	var WorkingHours = GlobalSave.GetValueFromSettingCategory("WorkingHours")
	var has_125 = false
	var has_150 = false
	var Deduction = GlobalSave.GetValueFromSettingCategory("SalaryDeduction")
	if Deduction != null:
		if Deduction.has("overtime125"):
			has_125 = Deduction["overtime125"]
		if Deduction.has("overtime150"):
			has_150 = Deduction["overtime150"]
	if WorkingHours != null:
		#Calculate in case 125 and 150
		if WorkingHours.has("hours") && has_125 && has_150:
			if TotalDailySeconds <= WorkingHours["hours"] * 3600:
				return [TotalDailySeconds,0,0]
			elif TotalDailySeconds > WorkingHours["hours"] * 3600 && TotalDailySeconds <= (WorkingHours["hours"]+2) * 3600:
				return [WorkingHours["hours"] * 3600,TotalDailySeconds-(WorkingHours["hours"] * 3600),0]
			else:
				return [WorkingHours["hours"] * 3600,(2 * 3600),(TotalDailySeconds-((WorkingHours["hours"]+2)* 3600))]
		#calculate if 125 and no 150
		if WorkingHours.has("hours") && has_125 && !has_150:
			if TotalDailySeconds <= WorkingHours["hours"] * 3600:
				return [TotalDailySeconds,0,0]
			else:
				return [WorkingHours["hours"] * 3600,TotalDailySeconds-(WorkingHours["hours"] * 3600),0]
		#calculate if no 125 and has 150
		if WorkingHours.has("hours") && !has_125 && has_150:
			if TotalDailySeconds <= WorkingHours["hours"] * 3600:
				return [TotalDailySeconds,0,0]
			else:
				return [WorkingHours["hours"] * 3600,0,TotalDailySeconds-(WorkingHours["hours"] * 3600)]
				
	else:
		return [TotalDailySeconds,0,0]
	
	return [TotalDailySeconds,0,0]
	

func ShowPopup(data):
	yield(get_tree(),"idle_frame")
	var p = load("res://Prefabs/Elements/ModulatePopupScreen.tscn").instance()
	get_node("/root/MainScreen").add_child(p)
	p.ShowModulate(data)
	var Answer = yield(p,"EmitedAnswer")
	return Answer
	
func WeekDayToDayName(DayNum):
	match DayNum:
		0:
			return [TranslationServer.translate("Sun"),TranslationServer.translate("Sunday")]
		1:
			return [TranslationServer.translate("Mon"),TranslationServer.translate("Monday")]
		2:
			return [TranslationServer.translate("Tu"),TranslationServer.translate("Tuesday")]
		3:
			return [TranslationServer.translate("We"),TranslationServer.translate("Wednesday")]
		4:
			return [TranslationServer.translate("Th"),TranslationServer.translate("Thursday")]
		5:
			return [TranslationServer.translate("Fr"),TranslationServer.translate("Friday")]
		6:
			return [TranslationServer.translate("Sa"),TranslationServer.translate("Saturday")]
			
func GetMonthName(MonthNum):
	match MonthNum:
		1:
			return [TranslationServer.translate("Jan"),TranslationServer.translate("January")]
		2:
			return [TranslationServer.translate("Feb"),TranslationServer.translate("February")]
		3:
			return [TranslationServer.translate("Mar"),TranslationServer.translate("March")]
		4:
			return [TranslationServer.translate("Apr"),TranslationServer.translate("April")]
		5:
			return [TranslationServer.translate("May_Small"),TranslationServer.translate("May_Big")]
		6:
			return [TranslationServer.translate("Jun"),TranslationServer.translate("June")]
		7:
			return [TranslationServer.translate("Jul"),TranslationServer.translate("July")]
		
		8:
			return [TranslationServer.translate("Aug"),TranslationServer.translate("August")]
		9:
			return [TranslationServer.translate("Sept"),TranslationServer.translate("September")]
		10:
			return [TranslationServer.translate("Oct"),TranslationServer.translate("October")]
		11:
			return [TranslationServer.translate("Nov"),TranslationServer.translate("November")]
		12:
			return [TranslationServer.translate("Dec"),TranslationServer.translate("December")]
