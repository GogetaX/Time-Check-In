extends Control

const DATE_JAN = 1
const DATE_FEB = 2
const DATE_MAR = 3
const DATE_APRIL = 4
const DATE_MAY = 5
const DATE_JUN = 6
const DATE_JUL = 7
const DATE_AUG = 8
const DATE_SEP = 9
const DATE_OCT = 10
const DATE_NOV = 11
const DATE_DEC = 12

const TIME_IDLE = "IDLE"
const TIME_CHECKED_IN = "CHECKED_IN"
const TIME_PAUSED = "PAUSED"
const TIME_RETRO_CHECK_IN = "RETRO_CHECK_IN"
const DAY_OFF_COLOR = Color.DARK_GREEN
const HOLIDAY_COLOR = Color.CHARTREUSE
const CURRENTDAY_COLOR = Color("#ffb326fb")
const MULTISELECT_COLOR = Color.YELLOW

var CurTimeMode = TIME_IDLE

var SecondTimer = null
var OldTime = null

var HasCheckin = []
var HasCheckOut = []

var DateDB = {}

var CurSelectedDate = {"day": 0, "month": 0, "year": 0}
var TempCurMonth = 0
var TempCurYear = 0
var ForgotCheckInYesterday = false
var ForgotCheckInSometimeAgo = null
var SwipeEnabled = true
var CurCalDaySelected = null
var ToolHandler = null

@warning_ignore("unused_signal")
signal InitSecond()
@warning_ignore("unused_signal")
signal TimeModeChangedTo(TimeMode)
# warning-ignore:unused_signal
@warning_ignore("unused_signal")
signal SelectDay(DayNode)
@warning_ignore("unused_signal")
signal BtnGroupPressed(BtnNode, GroupName)
# warning-ignore:unused_signal
@warning_ignore("unused_signal")
signal UpdateDayInfo()
# warning-ignore:unused_signal
@warning_ignore("unused_signal")
signal UpdateSpecificDayInfo(DayNumber, DayInfoData)
# warning-ignore:unused_signal
@warning_ignore("unused_signal")
signal ShowOnlyScreen(ScreenName)
# warning-ignore:unused_signal
@warning_ignore("unused_signal")
signal NoAnimShowWindow(ScreenName)
# warning-ignore:unused_signal
@warning_ignore("unused_signal")
signal ReloadCurrentDate()
# warning-ignore:unused_signal
@warning_ignore("unused_signal")
signal UpdateList()
# warning-ignore:unused_signal
@warning_ignore("unused_signal")
signal ScrollToCurrentDay(ListNode)
# warning-ignore:unused_signal
@warning_ignore("unused_signal")
signal ShowInterstitalAd()
# warning-ignore:unused_signal
@warning_ignore("unused_signal")
signal app_loaded()
# warning-ignore:unused_signal
@warning_ignore("unused_signal")
signal MultiSelect(Enabled)
@warning_ignore("unused_signal")
signal MultiSelectedDate(DayNode)
# warning-ignore:unused_signal
@warning_ignore("unused_signal")
signal CurScreenIndicator(IconTexture, txt)

func LoadTool(ToolName):
	var l = null
	match ToolName:
		"Export":
			l = load("res://Prefabs/Screens/ExporterScreen.tscn").instantiate()
		"Salary Simulator":
			l = load("res://Prefabs/Screens/SalarySimulatorScreen.tscn").instantiate()
		"Hour Editor":
			l = load("res://Prefabs/Screens/HourEditorScreen.tscn").instantiate()
	if l != null:
		ToolHandler.add_child(l)
		ToolHandler.move_child(l, ToolHandler.get_child_count() - 3)
	return l

func FreeTool(ToolNode):
	ToolNode.queue_free()

func _ready():
	InitSecondTimer()
	InitDates()

func InitDates():
	# Start of the week (1 = Sun), total_months, month_num, year_num
	# 2022
	AddDateDB(1, 31, 5, 2022)
	AddDateDB(4, 30, 6, 2022)
	AddDateDB(6, 31, 7, 2022)
	AddDateDB(2, 31, 8, 2022)
	AddDateDB(5, 30, 9, 2022)
	AddDateDB(7, 31, 10, 2022)
	AddDateDB(3, 30, 11, 2022)
	AddDateDB(5, 31, 12, 2022)
	# 2023
	AddDateDB(1, 31, 1, 2023)
	AddDateDB(4, 28, 2, 2023)
	AddDateDB(4, 31, 3, 2023)
	AddDateDB(7, 30, 4, 2023)
	AddDateDB(2, 31, 5, 2023)
	AddDateDB(5, 30, 6, 2023)
	AddDateDB(7, 31, 7, 2023)
	AddDateDB(3, 31, 8, 2023)
	AddDateDB(6, 30, 9, 2023)
	AddDateDB(1, 31, 10, 2023)
	AddDateDB(4, 30, 11, 2023)
	AddDateDB(6, 31, 12, 2023)
	# 2024
	AddDateDB(2, 31, 1, 2024)
	AddDateDB(5, 29, 2, 2024)
	AddDateDB(6, 31, 3, 2024)
	AddDateDB(2, 30, 4, 2024)
	AddDateDB(4, 31, 5, 2024)
	AddDateDB(7, 30, 6, 2024)
	AddDateDB(2, 31, 7, 2024)
	AddDateDB(5, 31, 8, 2024)
	AddDateDB(1, 30, 9, 2024)
	AddDateDB(3, 31, 10, 2024)
	AddDateDB(6, 30, 11, 2024)
	AddDateDB(1, 31, 12, 2024)
	# 2025
	AddDateDB(4, 31, DATE_JAN, 2025)
	AddDateDB(7, 28, DATE_FEB, 2025)
	AddDateDB(7, 31, DATE_MAR, 2025)
	AddDateDB(3, 30, DATE_APRIL, 2025)
	AddDateDB(5, 31, DATE_MAY, 2025)
	AddDateDB(1, 30, DATE_JUN, 2025)
	AddDateDB(3, 31, DATE_JUL, 2025)
	AddDateDB(6, 31, DATE_AUG, 2025)
	AddDateDB(2, 30, DATE_SEP, 2025)
	AddDateDB(4, 31, DATE_OCT, 2025)
	AddDateDB(7, 30, DATE_NOV, 2025)
	AddDateDB(2, 31, DATE_DEC, 2025)

func SelectCurDate(DayNode, DayInfo):
	CurCalDaySelected = DayNode
	CurSelectedDate["day"] = int(DayNode.text)
	CurSelectedDate["year"] = TempCurYear
	CurSelectedDate["month"] = TempCurMonth
	CurSelectedDate["info"] = DayInfo
	emit_signal("SelectDay", DayNode)

func MultiSelectDate(DayNode):
	emit_signal("MultiSelectedDate", DayNode)

func GetDifferenceBetweenDates(Date1, Date2):
	var res = {"year": abs(Date1["year"] - Date2["year"]), "month": abs(Date1["month"] - Date2["month"]), "day": abs(Date1["day"] - Date2["day"])}
	return res

func DateToDays(date):
	var year = date["year"] * 12 * 30
	var month = date["month"] * 30
	var day = date["day"]
	return year + month + day

func SelectCurDayList(Date, DayInfo):
	CurSelectedDate["day"] = Date["day"]
	CurSelectedDate["year"] = Date["year"]
	CurSelectedDate["month"] = Date["month"]
	CurSelectedDate["info"] = DayInfo

func GetColorFromReport(report):
	report = report.to_lower()
	match report:
		"day off":
			return DAY_OFF_COLOR
		"holiday":
			return HOLIDAY_COLOR
	return null

func HasPrevMonth(Month, Year):
	Month -= 1
	if Month <= 0:
		Year -= 1
		Month = 12
	if not DateDB.has(Year):
		return null
	if not DateDB[Year].has(Month):
		return null
	return DateDB[Year][Month]

func HasNextMonth(Month, Year):
	Month += 1
	if Month > 12:
		Year += 1
		Month = 1
	if not DateDB.has(Year):
		return null
	if not DateDB[Year].has(Month):
		return null
	return DateDB[Year][Month]

func DisplayFullDate(Date):
	var DayName = str(Date["day"])
	var MonthName = GetMonthName(Date["month"])[1]
	var YearName = str(Date["year"])
	return DayName + ", " + MonthName + " " + YearName

func HasNextYear(Month, Year):
	Year += 1
	if not DateDB.has(Year):
		return null
	if not DateDB[Year].has(Month):
		return null
	return DateDB[Year][Month]

func HasPrevYear(Month, Year):
	Year -= 1
	if not DateDB.has(Year):
		return null
	if not DateDB[Year].has(Month):
		return null
	return DateDB[Year][Month]

func GetDateInfo(Month, Year):
	return DateDB[Year][Month]

func AddDateDB(StartsFrom, TotDays, Month, Year):
	if not DateDB.has(Year):
		DateDB[Year] = {}
	if not DateDB[Year].has(Month):
		DateDB[Year][Month] = {"tot_days": TotDays, "start_from": StartsFrom}

func HowManyDaysInMonth(Date):
	if DateDB.has(Date["year"]):
		if DateDB[Date["year"]].has(Date["month"]):
			return DateDB[Date["year"]][Date["month"]]["tot_days"]
	return 0

func InitSecondTimer():
	OldTime = Time.get_datetime_dict_from_system()
	SecondTimer = Timer.new()
	add_child(SecondTimer)
	# SecondTimer.one_shot = false
	SecondTimer.connect("timeout", Callable(self, "timeout"))
	SecondTimer.start(-1)

func timeout():
	OldTime = Time.get_datetime_dict_from_system()
	emit_signal("InitSecond")

func AddRetroTimeChange(ToTimeMode, CurInfo):
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
			emit_signal("TimeModeChangedTo", CurTimeMode)
			return
	emit_signal("TimeModeChangedTo", ToTimeMode)

func FillCheckInOutArray(CheckInData, CheckOutData):
	var CurDate = Time.get_datetime_dict_from_system()
	if CheckInData["year"] != CurDate["year"] or CheckInData["month"] != CurDate["month"] or CheckInData["day"] != CurDate["day"]:
		return
	HasCheckOut = []
	HasCheckin = []
	HasCheckin.append(CheckInData)
	HasCheckOut.append(CheckOutData)

func ChangeTimeModes(ToTimeMode):
	CurTimeMode = ToTimeMode
	# ToMode
	match CurTimeMode:
		TIME_CHECKED_IN:
			HasCheckin.append(Time.get_datetime_dict_from_system())
			GlobalSave.AddCheckIn(Time.get_datetime_dict_from_system())
		TIME_PAUSED:
			HasCheckOut.append(Time.get_datetime_dict_from_system())
			GlobalSave.AddCheckOut(Time.get_datetime_dict_from_system())
	emit_signal("TimeModeChangedTo", ToTimeMode)

@warning_ignore("shadowed_global_identifier")
func TimeTo2DigitStr(Time):
	var t = str(Time)
	if t.length() == 1:
		t = "0" + t
	return t

func GetAllCheckInAndOuts(Info, max_check_outs = 2, translate = true):
	var Res = ""
	var Times = 1
	var TotChecks = 0
	var SelectedDay = {}
	for x in Info:
		if "check_in" in x:
			TotChecks += 1
			SelectedDay = Info[x]
			if Times == 1:
				Res = Res + TimeTo2DigitStr(Info[x]["hour"]) + ":" + TimeTo2DigitStr(Info[x]["minute"])
			elif Times > 1 and Times <= max_check_outs:
				Res = Res + ", " + TimeTo2DigitStr(Info[x]["hour"]) + ":" + TimeTo2DigitStr(Info[x]["minute"])
			else:
				if translate:
					Res = str(Times) + " " + TranslationServer.translate("Checkins") + ", " + TimeTo2DigitStr(Info[x]["hour"]) + ":" + TimeTo2DigitStr(Info[x]["minute"])
				else:
					var l = TranslationServer.get_locale()
					TranslationServer.set_locale("en")
					Res = str(Times) + " " + TranslationServer.translate("Checkins") + ", " + TimeTo2DigitStr(Info[x]["hour"]) + ":" + TimeTo2DigitStr(Info[x]["minute"])
					TranslationServer.set_locale(l)
		if "check_out" in x:
			TotChecks -= 1
			Res = Res + " - " + TimeTo2DigitStr(Info[x]["hour"]) + ":" + TimeTo2DigitStr(Info[x]["minute"])
			Times += 1
	var CurDay = Time.get_datetime_dict_from_system()
	if TotChecks == 1:
		if SelectedDay["day"] == CurDay["day"] and SelectedDay["month"] == CurDay["month"] and SelectedDay["year"] == CurDay["year"]:
			if translate:
				Res = Res + " - " + TranslationServer.translate("On_Going")
			else:
				var l = TranslationServer.get_locale()
				TranslationServer.set_locale("en")
				Res = Res + " - " + TranslationServer.translate("On_Going")
				TranslationServer.set_locale(l)
	return Res

func OffsetDay(CurDay, Offset_Day):
	var NewCurDay = CurDay.duplicate()
	NewCurDay["day"] += Offset_Day
	# Check backward
	if NewCurDay["day"] <= 0:
		NewCurDay["month"] -= 1
		if NewCurDay["month"] <= 0:
			NewCurDay["year"] -= 1
			NewCurDay["month"] = 12
		NewCurDay["day"] = DateDB[NewCurDay["year"]][NewCurDay["month"]]["tot_days"] - NewCurDay["day"]
	return NewCurDay

func CheckIfOnGoing(Info):
	var TotChecks = 0
	for x in Info:
		if "check_in" in x:
			TotChecks += 1
		if "check_out" in x:
			TotChecks -= 1
	if TotChecks > 0:
		return true
	return false

func CalcBetweenCheckinsTOSeconds(Info):
	var Num = 1
	var SecondsWorked = 0
	var TotSeconds = 0
	while Info.has("check_in" + str(Num)):
		SecondsWorked += Info["check_in" + str(Num)]["hour"] * 3600 + Info["check_in" + str(Num)]["minute"] * 60 + Info["check_in" + str(Num)]["second"]
		if Info.has("check_out" + str(Num)):
			SecondsWorked = (Info["check_out" + str(Num)]["hour"] * 3600 + Info["check_out" + str(Num)]["minute"] * 60 + Info["check_out" + str(Num)]["second"]) - SecondsWorked
			TotSeconds += SecondsWorked
			SecondsWorked = 0
		Num += 1
	return TotSeconds

func CalcHowLongWorked(Info):
	var SecondsWorked = 0
	var TotSeconds = 0
	var Num = 1
	var LastCheckIn = {}
	while Info.has("check_in" + str(Num)):
		SecondsWorked += Info["check_in" + str(Num)]["hour"] * 3600 + Info["check_in" + str(Num)]["minute"] * 60 + Info["check_in" + str(Num)]["second"]
		LastCheckIn = Info["check_in" + str(Num)]
		if Info.has("check_out" + str(Num)):
			SecondsWorked = (Info["check_out" + str(Num)]["hour"] * 3600 + Info["check_out" + str(Num)]["minute"] * 60 + Info["check_out" + str(Num)]["second"]) - SecondsWorked
			TotSeconds += SecondsWorked
			SecondsWorked = 0
		Num += 1
	var CurDate = Time.get_datetime_dict_from_system()
	var AddInSeconds = 0
	if LastCheckIn.has("year") and CurTimeMode == TIME_CHECKED_IN:
		if CurDate["year"] == LastCheckIn["year"] and CurDate["month"] == LastCheckIn["month"] and CurDate["day"] == LastCheckIn["day"]:
			AddInSeconds = (CurDate["hour"] - LastCheckIn["hour"]) * 3600
			AddInSeconds += (CurDate["minute"] - LastCheckIn["minute"]) * 60
			AddInSeconds += (CurDate["second"] - LastCheckIn["second"])
	var Date = SecondsToDate(TotSeconds + AddInSeconds)
	return Date

func FloatToString(FloatNum, Nums):
	# Seperating float <Num>.<Num>
	var Sides = str(FloatNum).split(".")
	if Sides.size() == 2:
		if Sides[1].length() == 1:
			Sides[1] = Sides[1] + "0"
		else:
			Sides[1] = Sides[1].substr(0, Nums)
	var a = Sides[0].length()
	var count = 0
	var r = ""
	while true:
		a -= 1
		r = Sides[0][a] + r
		count += 1
		if count == 3 and a != 0:
			r = "," + r
			count = 0
		if a == 0:
			break
	var NewRet = r
	if Sides.size() == 2:
		NewRet += "." + Sides[1]
	return NewRet

func ShowTime():
	var Min = str(OldTime["minute"])
	if Min.length() == 1:
		Min = "0" + Min
	return str(OldTime["hour"]) + ":" + Min

func ShowLastCheckIn():
	var T = GetLastCheckIn()
	var Min = str(T["minute"])
	if Min.length() == 1:
		Min = "0" + Min
	return str(T["hour"]) + ":" + Min

func GetLastCheckIn():
	return GlobalTime.HasCheckin[GlobalTime.HasCheckin.size() - 1]

func GetLastCheckOut():
	return GlobalTime.HasCheckOut[GlobalTime.HasCheckOut.size() - 1]

func CalcAllTimePassed():
	var Seconds = 0
	if HasCheckOut != []:
		for x in range(HasCheckOut.size()):
			Seconds += HasCheckOut[x]["second"] - HasCheckin[x]["second"]
			Seconds += (HasCheckOut[x]["minute"] - HasCheckin[x]["minute"]) * 60
			Seconds += (HasCheckOut[x]["hour"] - HasCheckin[x]["hour"]) * 3600
			Seconds += (HasCheckOut[x]["day"] - HasCheckin[x]["day"]) * 86400
	var CurTime = Time.get_datetime_dict_from_system()
	if CurTimeMode == TIME_PAUSED:
		CurTime = GetLastCheckOut()
	return CalcTimePassed(GetLastCheckIn(), CurTime, Seconds)

func SyncCurDay(Date):
	var CurDay = Time.get_datetime_dict_from_system()
	if CurDay["day"] == Date["day"] and CurDay["month"] == Date["month"] and CurDay["year"] == Date["year"]:
		GlobalSave.emit_signal("UpdateToday")

func CalcAllCheckInsAndOutsToSeconds():
	var Seconds = 0
	if HasCheckOut != []:
		for x in range(HasCheckOut.size()):
			Seconds += HasCheckOut[x]["second"] - HasCheckin[x]["second"]
			Seconds += (HasCheckOut[x]["minute"] - HasCheckin[x]["minute"]) * 60
			Seconds += (HasCheckOut[x]["hour"] - HasCheckin[x]["hour"]) * 3600
			Seconds += (HasCheckOut[x]["day"] - HasCheckin[x]["day"]) * 86400
			if x == HasCheckOut.size() - 1:
				if HasCheckin.size() > HasCheckOut.size():
					var CurDate = Time.get_datetime_dict_from_system()
					Seconds += CurDate["second"] - HasCheckin[x + 1]["second"]
					Seconds += (CurDate["minute"] - HasCheckin[x + 1]["minute"]) * 60
					Seconds += (CurDate["hour"] - HasCheckin[x + 1]["hour"]) * 3600
					Seconds += (CurDate["day"] - HasCheckin[x + 1]["day"]) * 86400
	else:
		if HasCheckin.size() > HasCheckOut.size():
			var CurDate = Time.get_datetime_dict_from_system()
			Seconds += CurDate["second"] - HasCheckin[0]["second"]
			Seconds += (CurDate["minute"] - HasCheckin[0]["minute"]) * 60
			Seconds += (CurDate["hour"] - HasCheckin[0]["hour"]) * 3600
			Seconds += (CurDate["day"] - HasCheckin[0]["day"]) * 86400
	return Seconds

func TimeToString(Seconds):
	var Date = SecondsToDate(Seconds)
	if Date["day"] > 0:
		var res = TranslationServer.translate("days_and_hours").format([str(Date["day"]), str(Date["hour"])])
		return res
	if Date["hour"] > 0:
		var res = TranslationServer.translate("hours_and_minutes").format([str(Date["hour"]), str(Date["minute"])])
		return res
	if Date["minute"] > 0:
		var res = TranslationServer.translate("minutes_and_seconds").format([str(Date["minute"]), str(Date["second"])])
		return res
	return TranslationServer.translate("second_info") % str(Date["second"])

func HowManyCheckIns(date):
	var ret = 0
	for x in date:
		if "check_in" in x:
			ret += 1
	return ret

func HowMuchIEarnedFromSeconds(Seconds):
	var Ret = 0
	var WithNosafot = GetHowManySecondsOnNosafot(Seconds)
	var sufix = ""
	var SalorySettings = GlobalSave.GetValueFromSettingCategory("SaloryCalculation")
	if SalorySettings == null:
		return [0, ""]
	if SalorySettings.has("sufix"):
		sufix = SalorySettings["sufix"]
	if Seconds == 0 or not SalorySettings.has("salary"):
		return [0, sufix]
	Ret = (WithNosafot[0] / 3600.0 * SalorySettings["salary"]) + (WithNosafot[1] / 3600.0 * SalorySettings["salary"]) * 1.25 + (WithNosafot[2] / 3600.0 * SalorySettings["salary"]) * 1.5
	return [Ret, sufix]

func CalcTimePassedFull(FromTime, ToTime):
	var FromSeconds = DateToSeconds(FromTime)
	var ToSeconds = DateToSeconds(ToTime)
	var SecondsPassed = ToSeconds - FromSeconds
	var Date = SecondsToDate(SecondsPassed)
	var minute = str(Date["minute"])
	if minute.length() == 1:
		minute = "0" + minute
	return str(Date["hour"]) + ":" + minute

func CalcTimePassed(FromTime, ToTime, PlusSeconds = 0):
	var FromSeconds = DateToSeconds(FromTime)
	var ToSeconds = DateToSeconds(ToTime)
	var SecondsPassed = ToSeconds - FromSeconds
	var Date = SecondsToDate(SecondsPassed + PlusSeconds)
	var Res = ""
	if Date["day"] > 0:
		Res += str(Date["day"]) + ":"
	if Date["hour"] > 0:
		Res += str(Date["hour"]) + ":"
	var Min = str(Date["minute"])
	if Min.length() == 1:
		Min = "0" + Min
	if Date["minute"] > 0:
		Res += Min + ":"
	var Sec = str(Date["second"])
	if Sec.length() == 1:
		Sec = "0" + Sec
	Res += Sec
	if Date["minute"] == 0 and Date["hour"] == 0:
		Res += " " + TranslationServer.translate("Seconds")
	return Res

func SecondsToDate(Seconds):
	var Date = {"second": 0, "minute": 0, "hour": 0, "day": 0}
	while Seconds >= 86400:
		if Seconds < 86400:
			break
		Date["day"] += 1
		Seconds -= 86400
	while Seconds >= 3600:
		if Seconds < 3600:
			break
		Date["hour"] += 1
		Seconds -= 3600
	while Seconds >= 60:
		if Seconds < 60:
			break
		Date["minute"] += 1
		Seconds -= 60
	Date["second"] = Seconds
	return Date

func ShowDate():
	return WeekDayToDayName(OldTime["weekday"])[1] + ", " + GetMonthName(OldTime["month"])[0] + " " + str(OldTime["day"]) + ", " + str(OldTime["year"])

func ShowSeconds():
	var Sec = str(OldTime["second"])
	if Sec.length() == 1:
		Sec = "0" + Sec
	return Sec

func DateToSeconds(Date):
	var Res = 0
	if Date.has("day"):
		Res += Date["day"] * 86400
	if Date.has("hour"):
		Res += Date["hour"] * 3600
	if Date.has("minute"):
		Res += Date["minute"] * 60
	if Date.has("second"):
		Res += Date["second"]
	return Res

func FilterChecksIns(CheckInData):
	for x in CheckInData:
		if "check_in" in x:
			var Num = x.replace("check_in", "")
			if CheckInData.has("check_out" + Num):
				if CheckInData[x]["hour"] * 3600 + CheckInData[x]["minute"] * 60 > CheckInData["check_out" + Num]["hour"] * 3600 + CheckInData["check_out" + Num]["minute"] * 60:
					CheckInData["check_out" + Num]["hour"] = 24 + CheckInData["check_out" + Num]["hour"]
	return CheckInData

func IsraelIncomeCalcFromSalary(SecondsWorked, Sec125, Sec150, custom_salary = 0):
	# Values Updated Every Year
	# TaxInfo, TaxMore Info: https://www.kolzchut.org.il/he/%D7%9E%D7%93%D7%A8%D7%92%D7%95%D7%AA_%D7%9E%D7%A1_%D7%94%D7%9B%D7%A0%D7%A1%D7%94
	var TaxInfo = [[6790, 10.0], [9730, 14.0], [15620, 20.0], [21710, 31.0], [45180, 35.0], [58190, 47.0]]
	var TaxMore = 50.0
	# CreditAmount Info Nekudot Zokui: https://www.kolzchut.org.il/he/%D7%A0%D7%A7%D7%95%D7%93%D7%AA_%D7%96%D7%99%D7%9B%D7%95%D7%99
	var CreditAmount = 223
	# TaxHealth, TaxSocial, AvarageSalary Info: https://www.btl.gov.il/Insurance/Rates/Pages/%D7%9C%D7%A2%D7%95%D7%91%D7%93%D7%99%D7%9D%20%D7%A9%D7%9B%D7%99%D7%A8%D7%99%D7%9D.aspx
	var AvarageSalary = 7122  # 2022: 6331
	var TaxHealth = [3.1, 5]
	var TaxSocial = [0.4, 7]
	# -------------------------------------------
	var Salary = GlobalSave.GetValueFromSettingCategory("SaloryCalculation")
	if Salary == null:
		return {"no_info_on_salary": ""}
	var GrossSalary = 0
	if custom_salary == 0:
		GrossSalary = (SecondsWorked / 3600.0 * Salary["salary"]) + (Sec125 / 3600.0 * Salary["salary"] * 1.25) + (Sec150 / 3600.0 * Salary["salary"] * 1.50) + Salary["bonus"]
	else:
		GrossSalary = custom_salary
	# GrossSalary =  13480+4137.3
	var Credit = 2.25
	var LastTaxPercent = TaxInfo[0][1]
	var S = GlobalSave.GetValueFromSettingCategory("SalaryDeduction")
	var sufix = ""
	if Salary.has("sufix"):
		sufix = TranslationServer.translate(Salary["sufix"])
	if S.has("credit"):
		Credit = S["credit"]
	# Tax should be 2295.95
	# TaxInfo
	# Gross, Income tax, Social security, Health tax, Net
	var Rest = {"Gross": FloatToString(GrossSalary, 2) + sufix}
	if Sec125 > 0:
		Rest["NosafotHours 125%"] = FloatToString(Sec125 / 3600.0, 1)
		Rest["NosafotEarned 125%"] = FloatToString(Sec125 / 3600.0 * Salary["salary"] * 1.25, 2) + sufix
	if Sec150 > 0:
		Rest["NosafotHours 150%"] = FloatToString(Sec150 / 3600.0, 1)
		Rest["NosafotEarned 150%"] = FloatToString(Sec150 / 3600.0 * Salary["salary"] * 1.50, 2) + sufix
	var NetList = []
	if GrossSalary <= TaxInfo[0][0]:
		Rest["Income-tax-percent"] = str(TaxInfo[0][1]) + "%"
		Rest["Income-tax"] = (GrossSalary * TaxInfo[0][1]) / 100.0
	else:
		var LastValue = 0
		for Tax in TaxInfo:
			if GrossSalary >= Tax[0]:
				var T = ((Tax[0] - LastValue) * Tax[1]) / 100.0
				NetList.append(T)
				LastValue = Tax[0]
				LastTaxPercent = Tax[1]
			else:
				var T = ((GrossSalary - LastValue) * Tax[1]) / 100.0
				LastTaxPercent = Tax[1]
				NetList.append(T)
				break
		if GrossSalary > TaxInfo[TaxInfo.size() - 1][0]:
			var T = ((GrossSalary - LastValue) * TaxMore) / 100.0
			LastTaxPercent = TaxMore
			NetList.append(T)
		var Tax = 0
		for x in NetList:
			Tax += x
		Rest["Income-tax-percent"] = str(LastTaxPercent) + "%"
		Rest["Income-tax"] = Tax
	if Rest["Income-tax"] > (Credit * CreditAmount):
		Rest["Income-tax"] -= (Credit * CreditAmount)
		Rest["Income-tax-percent"] = str(LastTaxPercent) + "%"
	# Calc Health Tax Security
	Rest["Social-security"] = 0
	Rest["Health-tax"] = 0
	if GrossSalary <= AvarageSalary:
		Rest["Health-tax"] = (GrossSalary) * TaxHealth[0] / 100
	else:
		Rest["Health-tax"] = (AvarageSalary) * TaxHealth[0] / 100
		Rest["Health-tax"] += (GrossSalary - AvarageSalary) * TaxHealth[1] / 100
	if GrossSalary <= AvarageSalary:
		Rest["Social-security"] = (GrossSalary) * TaxSocial[0] / 100
	else:
		Rest["Social-security"] = (AvarageSalary) * TaxSocial[0] / 100
		Rest["Social-security"] += (GrossSalary - AvarageSalary) * TaxSocial[1] / 100
	Rest["Net"] = GrossSalary - Rest["Social-security"] - Rest["Health-tax"] - Rest["Income-tax"]
	Rest["Health-tax"] = FloatToString(Rest["Health-tax"], 2) + sufix
	Rest["Social-security"] = FloatToString(Rest["Social-security"], 2) + sufix
	Rest["Income-tax"] = FloatToString(Rest["Income-tax"], 2) + sufix
	Rest["Net"] = FloatToString(Rest["Net"], 2) + sufix
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
		# Calculate in case 125 and 150
		if WorkingHours.has("hours") and has_125 and has_150:
			if TotalDailySeconds <= WorkingHours["hours"] * 3600:
				return [TotalDailySeconds, 0, 0]
			elif TotalDailySeconds > WorkingHours["hours"] * 3600 and TotalDailySeconds <= (WorkingHours["hours"] + 2) * 3600:
				return [WorkingHours["hours"] * 3600, TotalDailySeconds - (WorkingHours["hours"] * 3600), 0]
			else:
				return [WorkingHours["hours"] * 3600, (2 * 3600), (TotalDailySeconds - ((WorkingHours["hours"] + 2) * 3600))]
		# Calculate if 125 and no 150
		if WorkingHours.has("hours") and has_125 and not has_150:
			if TotalDailySeconds <= WorkingHours["hours"] * 3600:
				return [TotalDailySeconds, 0, 0]
			else:
				return [WorkingHours["hours"] * 3600, TotalDailySeconds - (WorkingHours["hours"] * 3600), 0]
		# Calculate if no 125 and has 150
		if WorkingHours.has("hours") and not has_125 and has_150:
			if TotalDailySeconds <= WorkingHours["hours"] * 3600:
				return [TotalDailySeconds, 0, 0]
			else:
				return [WorkingHours["hours"] * 3600, 0, TotalDailySeconds - (WorkingHours["hours"] * 3600)]
	else:
		return [TotalDailySeconds, 0, 0]
	return [TotalDailySeconds, 0, 0]

func ShowPopup(data):
	await get_tree().process_frame
	var p = load("res://Prefabs/Elements/ModulatePopupScreen.tscn").instantiate()
	get_node("/root/MainScreen").add_child(p)
	p.ShowModulate(data)
	var Answer = await p.EmitedAnswer
	return Answer

func ShowKeypad(self_node, On_Entry, exclude_buttons = ""):
	var p = load("res://Prefabs/Elements/NumpadKeyboard.tscn").instantiate()
	get_node("/root/MainScreen").add_child(p)
	p.ShowModulate(exclude_buttons)
	p.connect("OnEntry", Callable(self_node, On_Entry))
	return p

func GetWeekNumFromDate(Date):
	var D = Date["day"] + DateDB[Date["year"]][Date["month"]]["start_from"] - 2
	while D >= 7:
		D -= 7
	return D

func WeekDayToDayName(DayNum):
	match DayNum:
		0:
			return [TranslationServer.translate("Sun"), TranslationServer.translate("Sunday")]
		1:
			return [TranslationServer.translate("Mon"), TranslationServer.translate("Monday")]
		2:
			return [TranslationServer.translate("Tue"), TranslationServer.translate("Tuesday")]
		3:
			return [TranslationServer.translate("Wed"), TranslationServer.translate("Wednesday")]
		4:
			return [TranslationServer.translate("Thu"), TranslationServer.translate("Thursday")]
		5:
			return [TranslationServer.translate("Fri"), TranslationServer.translate("Friday")]
		6:
			return [TranslationServer.translate("Sat"), TranslationServer.translate("Saturday")]

func GetMonthName(MonthNum):
	match MonthNum:
		1:
			return [TranslationServer.translate("Jan"), TranslationServer.translate("January")]
		2:
			return [TranslationServer.translate("Feb"), TranslationServer.translate("February")]
		3:
			return [TranslationServer.translate("Mar"), TranslationServer.translate("March")]
		4:
			return [TranslationServer.translate("Apr"), TranslationServer.translate("April")]
		5:
			return [TranslationServer.translate("May_Small"), TranslationServer.translate("May_Big")]
		6:
			return [TranslationServer.translate("Jun"), TranslationServer.translate("June")]
		7:
			return [TranslationServer.translate("Jul"), TranslationServer.translate("July")]
		8:
			return [TranslationServer.translate("Aug"), TranslationServer.translate("August")]
		9:
			return [TranslationServer.translate("Sept"), TranslationServer.translate("September")]
		10:
			return [TranslationServer.translate("Oct"), TranslationServer.translate("October")]
		11:
			return [TranslationServer.translate("Nov"), TranslationServer.translate("November")]
		12:
			return [TranslationServer.translate("Dec"), TranslationServer.translate("December")]
