extends Control

const TIME_IDLE = "IDLE"
const TIME_CHECKED_IN = "CHECKED_IN"
const TIME_PAUSED = "PAUSED"
var CurTimeMode = TIME_IDLE

var SecondTimer = null
var OldTime = null

var HasCheckin = []
var HasCheckOut = []

var DateDB = {}

var CurSelectedDate = {"day": 0,"month":0,"year":0}
var TempCurMonth = 0
var TempCurYear = 0


signal InitSecond()
signal TimeModeChangedTo(TimeMode)
# warning-ignore:unused_signal
signal SelectDay(DayNode)
signal BtnGroupPressed(BtnNode,GroupName)


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
	
func GetAllCheckInAndOuts(Info):
	var Res = ""
	var Times = 1
	for x in Info:
		if "check_in" in x:
			if Times == 1:
				Res = Res + String(Info[x]["hour"])+":"+String(Info[x]["minute"])
			else:
				Res = Res+", " + String(Info[x]["hour"])+":"+String(Info[x]["minute"])
		if "check_out" in x:
			Res = Res +" - "+String(Info[x]["hour"])+":"+String(Info[x]["minute"])
			Times+= 1
	return Res
	
func CalcHowLongWorked(Info):
	var SecondsWorked = 0
	var TotSeconds = 0
	var Num = 1
	while Info.has("check_in"+String(Num)):
		SecondsWorked += Info["check_in"+String(Num)]["hour"]*3600+Info["check_in"+String(Num)]["minute"]*60+Info["check_in"+String(Num)]["second"]
		
		if Info.has("check_out"+String(Num)):
			SecondsWorked = (Info["check_out"+String(Num)]["hour"]*3600+Info["check_out"+String(Num)]["minute"]*60+Info["check_out"+String(Num)]["second"])-SecondsWorked
			TotSeconds += SecondsWorked
			SecondsWorked = 0
		Num += 1
	var Date = SecondsToDate(TotSeconds)
	return Date
	
	
func ShowTime():
	var Min = String(OldTime["minute"])
	if Min.length() == 1:
		Min = "0"+Min
	return String(OldTime["hour"])+":"+Min
	
func GetLastCheckIn():
	return GlobalTime.HasCheckin[GlobalTime.HasCheckin.size()-1]
	
func CalcAllTimePassed():
	var Seconds = 0
	if HasCheckOut != []:
		for x in range(HasCheckOut.size()):
			Seconds += HasCheckOut[x]["second"]-HasCheckin[x]["second"]
			Seconds += (HasCheckOut[x]["minute"]-HasCheckin[x]["minute"])*60
			Seconds += (HasCheckOut[x]["hour"]-HasCheckin[x]["hour"])*3600
			Seconds += (HasCheckOut[x]["day"]-HasCheckin[x]["day"])*86400
			
	return GlobalTime.CalcTimePassed(GlobalTime.GetLastCheckIn(),OS.get_datetime(),Seconds)
	
func CalcTimePassed(FromTime,ToTime,PlusSeconds = 0):
	var SecondsPassed = ToTime["second"]-FromTime["second"]
	SecondsPassed += ToTime["minute"]*60-FromTime["minute"]*60
	SecondsPassed += PlusSeconds
	var Date = SecondsToDate(SecondsPassed)
	
	var Res = ""
	if Date["day"]>0:
		Res += String(Date["day"])+":"
	if Date["hour"]>0:
		Res += String(Date["hour"])+":"
		
	if Date["minute"]>0:
		Res += String(Date["minute"])+":"
	
	var Sec = String(Date["second"])
	if Sec.length() == 1:
		Sec = "0"+Sec
	Res += Sec
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
	return WeekDayToDayName(OldTime["weekday"])+", "+GetMonthName(OldTime["month"])[0]+" "+String(OldTime["day"])+", "+String(OldTime["year"])
	
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
	
func WeekDayToDayName(DayNum):
	match DayNum:
		1:
			return "Sun"
		2:
			return "Mon"
		3:
			return "Tu"
		4:
			return "We"
		5:
			return "Th"
		6:
			return "Fr"
		7:
			return "Sa"
func GetMonthName(MonthNum):
	match MonthNum:
		1:
			return ["Jan","January"]
		2:
			return ["Feb","February"]
		3:
			return ["Mar","March"]
		4:
			return ["Apr","April"]
		5:
			return ["May","May"]
		6:
			return ["Jun","June"]
		7:
			return ["Jul","July"]
		
		8:
			return ["Aug","August"]
		9:
			return ["Sept","September"]
		10:
			return ["Oct","October"]
		11:
			return ["Nov","November"]
		12:
			return ["Dec","December"]
