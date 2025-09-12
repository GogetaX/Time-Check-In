extends Node

# warning-ignore:unused_signal
@warning_ignore("unused_signal")
signal UpdateLanguange()
@warning_ignore("unused_signal")
signal UpdateToday()

var MySaves = {}
var MySettings = {}

func _ready():
	LoadSettings()
	# warning-ignore:return_value_discarded
	connect("UpdateLanguange", Callable(self, "ClearAllData"))

func ClearAllData():
	GlobalTime.HasCheckin = []
	GlobalTime.HasCheckOut = []

func AddCheckIn(CheckInDate):
	AddMySavesPath(CheckInDate)
	var C = FindEmptyCheckIn(MySaves[CheckInDate["year"]][CheckInDate["month"]][CheckInDate["day"]])
	MySaves[CheckInDate["year"]][CheckInDate["month"]][CheckInDate["day"]]["check_in" + str(C)] = CheckInDate
	SaveToFile()

func FindEmptyCheckIn(data):
	var empty = 1
	while data.has("check_in" + str(empty)):
		empty += 1
	return empty

func FindLastCheckIn(data):
	var last = 1
	while data.has("check_in" + str(last)):
		last += 1
	last -= 1
	return last

func FindFirstCheckIn(data):
	if data.has("check_in1"):
		return data["check_in1"]
	return null

func AddCheckOut(CheckOutDate):
	AddMySavesPath(CheckOutDate)
	var L = FindLastCheckIn(MySaves[CheckOutDate["year"]][CheckOutDate["month"]][CheckOutDate["day"]])
	MySaves[CheckOutDate["year"]][CheckOutDate["month"]][CheckOutDate["day"]]["check_out" + str(L)] = CheckOutDate
	SaveToFile()

func AddDayOff(DayOffDay):
	AddMySavesPath(DayOffDay)
	MySaves[DayOffDay["year"]][DayOffDay["month"]][DayOffDay["day"]]["report"] = "Day Off"
	SaveToFile()

func AddHoliday(DayOffDay):
	AddMySavesPath(DayOffDay)
	MySaves[DayOffDay["year"]][DayOffDay["month"]][DayOffDay["day"]]["report"] = "Holiday"
	SaveToFile()

func RemoveReport(Date):
	AddMySavesPath(Date)
	if MySaves[Date["year"]][Date["month"]][Date["day"]].has("report"):
		MySaves[Date["year"]][Date["month"]][Date["day"]].erase("report")
	var CurDate = Time.get_datetime_dict_from_system()
	SaveToFile()
	if Date["day"] == CurDate["day"] and Date["month"] == CurDate["month"] and Date["year"] == CurDate["year"]:
		emit_signal("UpdateToday")
	GlobalTime.emit_signal("UpdateSpecificDayInfo", Date["day"], MySaves[Date["year"]][Date["month"]][Date["day"]])

func HasTodayReport():
	var CurDate = Time.get_datetime_dict_from_system()
	if not MySaves.has(CurDate["year"]):
		return null
	if not MySaves[CurDate["year"]].has(CurDate["month"]):
		return null
	if not MySaves[CurDate["year"]][CurDate["month"]].has(CurDate["day"]):
		return null
	if not MySaves[CurDate["year"]][CurDate["month"]][CurDate["day"]].has("report"):
		return null
	return MySaves[CurDate["year"]][CurDate["month"]][CurDate["day"]]["report"]

func GetTodayInfo():
	var CurDate = Time.get_datetime_dict_from_system()
	if not MySaves.has(CurDate["year"]):
		return null
	if not MySaves[CurDate["year"]].has(CurDate["month"]):
		return null
	if not MySaves[CurDate["year"]][CurDate["month"]].has(CurDate["day"]):
		return null
	return MySaves[CurDate["year"]][CurDate["month"]][CurDate["day"]]

func RemoveCheckOut(CheckOutNum, Date):
	var CurYear = GlobalTime.CurSelectedDate["year"]
	var CurMonth = GlobalTime.CurSelectedDate["month"]
	if MySaves[CurYear][CurMonth].has(Date["day"]):
		if MySaves[CurYear][CurMonth][Date["day"]].has("check_out" + str(CheckOutNum)):
			MySaves[CurYear][CurMonth][Date["day"]].erase("check_out" + str(CheckOutNum))
		else:
			print("Error, Checking not existing ", Date, " checkinnum ", CheckOutNum)
	else:
		print("Error, No date found to remove ", Date)
	MySaves[CurYear][CurMonth][Date["day"]] = ReformatCheckins(MySaves[CurYear][CurMonth][Date["day"]])
	SaveToFile()

func RemoveDayComplete(Date):
	if not MySaves.has(Date["year"]):
		return
	if not MySaves[Date["year"]].has(Date["month"]):
		return
	if MySaves[Date["year"]][Date["month"]].has(Date["day"]):
		MySaves[Date["year"]][Date["month"]][Date["day"]] = {}
	SaveToFile()

func RemoveCheckInOut(CheckInNum, Date):
	var CurYear = GlobalTime.CurSelectedDate["year"]
	var CurMonth = GlobalTime.CurSelectedDate["month"]
	if MySaves[CurYear][CurMonth].has(Date["day"]):
		if MySaves[CurYear][CurMonth][Date["day"]].has("check_in" + str(CheckInNum)):
			MySaves[CurYear][CurMonth][Date["day"]].erase("check_in" + str(CheckInNum))
		if MySaves[CurYear][CurMonth][Date["day"]].has("check_out" + str(CheckInNum)):
			MySaves[CurYear][CurMonth][Date["day"]].erase("check_out" + str(CheckInNum))
		else:
			print("Error, Checking not existing ", Date, " checkinnum ", CheckInNum)
	else:
		print("Error, No date found to remove ", Date)
	MySaves[CurYear][CurMonth][Date["day"]] = ReformatCheckins(MySaves[CurYear][CurMonth][Date["day"]])
	SaveToFile()

func AddAditionalReportOptions(NodeName):
	var MetaData = NodeName.get_popup().get_item_count()
	NodeName.get_popup().add_icon_item(ReportToImage("Forgot Check-in?"), "Forgot Check-in?")
	NodeName.get_popup().set_item_metadata(MetaData, "Forgot Check-in?")

func AddReportOptionsToNode(NodeName, ExcludeWorkDay = false):
	var MetaData = 0
	NodeName.get_popup().add_icon_item(GlobalSave.ReportToImage("Day Off"), "Day off")
	NodeName.get_popup().set_item_metadata(MetaData, "Day off")
	MetaData += 1
	NodeName.get_popup().add_icon_item(GlobalSave.ReportToImage("Holiday"), "Holiday")
	NodeName.get_popup().set_item_metadata(MetaData, "Holiday")
	MetaData += 1
	if not ExcludeWorkDay:
		NodeName.get_popup().add_icon_item(GlobalSave.ReportToImage("Work day"), "Work day")
		NodeName.get_popup().set_item_metadata(MetaData, "Work day")
		MetaData += 1
	if OS.get_name() == "Windows":
		NodeName.get_popup().add_icon_item(GlobalSave.ReportToImage("Work day"), "Check In")
		NodeName.get_popup().set_item_metadata(MetaData, "Check In")

func AddCustomListOptionsToNode(NodeName: MenuButton, array):
	var MetaData = 0
	for x in array:
		NodeName.get_popup().add_item(TranslationServer.translate(x))
		NodeName.get_popup().set_item_metadata(MetaData, x)
		MetaData += 1

func ReportToImage(ReportText):
	match ReportText:
		"Day Off":
			return load("res://Assets/Icons/day.png")
		"Holiday":
			return load("res://Assets/Icons/holidays.png")
		"Work day":
			return load("res://Assets/Icons/hard-work.png")
		"Forgot Check-in?":
			return load("res://Assets/Icons/confusion.png")
		_:
			return null

func ReformatCheckins(CheckInData):
	var Num = 0
	var Res = {}
	for x in CheckInData:
		if "check_in" in x:
			Num += 1
			var CurCheckIn = int(x.replace("check_in", ""))
			Res["check_in" + str(Num)] = CheckInData[x]
			if CheckInData.has("check_out" + str(CurCheckIn)):
				Res["check_out" + str(Num)] = CheckInData["check_out" + str(CurCheckIn)]
	return Res

func AddMySavesPath(Date):
	if not MySaves.has(Date["year"]):
		MySaves[Date["year"]] = {}
	if not MySaves[Date["year"]].has(Date["month"]):
		MySaves[Date["year"]][Date["month"]] = {}
	if not MySaves[Date["year"]][Date["month"]].has(Date["day"]):
		MySaves[Date["year"]][Date["month"]][Date["day"]] = {}

func SaveToFile():
	for year in MySaves:
		for month in MySaves[year]:
			var F = FileAccess.open(GlobalIosArrange.UserPath + "SaveFile" + str(year * month) + ".sf", FileAccess.WRITE)
			F.store_var(MySaves[year][month])
			F.close()

func GetAllDateFiles():
	var files = []
	var dir = DirAccess.open(GlobalIosArrange.UserPath)
	dir.list_dir_begin()  # List files with .sf extension, exclude hidden files
	var file = dir.get_next()
	while file != "":
		if file.begins_with("SaveFile") and file.ends_with(".sf"):
			files.append(file)
		file = dir.get_next()
	dir.list_dir_end()
	return files

func LoadDateForExport(Month, Year):
	var Res = null
	if not FileAccess.file_exists(GlobalIosArrange.UserPath + "SaveFile" + str(Year * Month) + ".sf"):
		return null
	var F = FileAccess.open(GlobalIosArrange.UserPath + "SaveFile" + str(Year * Month) + ".sf", FileAccess.READ)
	Res = F.get_var()
	F.close()
	return Res

func LoadSpecificFile(Month, Year, find_before = true):
	var Res = null
	if FileAccess.file_exists(GlobalIosArrange.UserPath + "SaveFile" + str(Year * Month) + ".sf"):
		var F = FileAccess.open(GlobalIosArrange.UserPath + "SaveFile" + str(Year * Month) + ".sf", FileAccess.READ)
		Res = F.get_var()
		F.close()
	if Res != null:
		for x in Res:
			var DateToAdd = {"year": Year, "month": Month, "day": x}
			AddMySavesPath(DateToAdd)
			MySaves[Year][Month][x] = Res[x]
	# Find if there are dates checked out in last days and do checkout on 00:00
	var CurDate = Time.get_datetime_dict_from_system()
	if Res != null and find_before:
		for x in Res:
			if CurDate["year"] > Year or CurDate["month"] > Month or CurDate["day"] > x:
				var CheckIns = 0
				# warning-ignore:unused_variable
				@warning_ignore("unused_variable")
				var LastCheckIn = 0
				for Day in Res[x]:
					if "check_in" in Day:
						CheckIns += 1
						LastCheckIn = int(Day.replace("check_in", ""))
					if "check_out" in Day:
						CheckIns -= 1
				if CheckIns > 0:
					var NewCheckOut = {"year": Year, "month": Month, "day": x, "hour": 24, "minute": 0, "second": 0}
					var Yesterday = GlobalTime.OffsetDay(CurDate, -1)
					if CurDate["month"] != Yesterday["month"] or CurDate["year"] != Yesterday["year"]:
						var _yest = LoadSpecificFile(Yesterday["month"], Yesterday["year"], false)
					if Yesterday["year"] == NewCheckOut["year"] and Yesterday["month"] == NewCheckOut["month"] and Yesterday["day"] == NewCheckOut["day"]:
						GlobalTime.ForgotCheckInYesterday = true
					else:
						GlobalTime.ForgotCheckInSometimeAgo = NewCheckOut
					AddCheckOut(NewCheckOut)
	return Res

func SaveSettings():
	var F = FileAccess.open(GlobalIosArrange.UserPath + "Settings.ini", FileAccess.WRITE)
	F.store_var(MySettings)
	F.close()

func AddVarsToSettings(Category, Key, Value):
	if not MySettings.has(Category):
		MySettings[Category] = {}
	MySettings[Category][Key] = Value
	SaveSettings()

func RemoveSettingByCategory(Category):
	if MySettings.has(Category):
		MySettings.erase(Category)
	SaveSettings()

func LoadSettings():
	if not FileAccess.file_exists(GlobalIosArrange.UserPath + "Settings.ini"):
		return
	var F = FileAccess.open(GlobalIosArrange.UserPath + "Settings.ini", FileAccess.READ)
	MySettings = F.get_var()
	F.close()
	var Lang = GetValueFromSettingCategory("Languange")
	if Lang != null:
		if Lang.has("lang"):
			TranslationServer.set_locale(LanguangeToLetters(Lang["lang"]))

func LanguangeToLetters(Lang):
	match Lang:
		"English":
			return "en"
		"Hebrew":
			return "he"
		"Russian":
			return "ru"
		_:
			print("Languange ", Lang, " not supported yet. (GlobalSave->LanguangeToLetters)")

func HowManyMonthsWorked():
	var files = []
	var dir = DirAccess.open(GlobalIosArrange.UserPath)
	dir.list_dir_begin()  # List files with .sf extension, exclude hidden files
	var file = dir.get_next()
	while file != "":
		if file.ends_with(".sf"):
			files.append(file)
		file = dir.get_next()
	dir.list_dir_end()
	return files

func GetValueFromSettings(Category, Key):
	if not MySettings.has(Category):
		return null
	if not MySettings[Category].has(Key):  # Fixed bug: was MySaves instead of MySettings
		return null
	return MySettings[Category][Key]

func GetValueFromSettingCategory(Category):
	if not MySettings.has(Category):
		return null
	return MySettings[Category]
