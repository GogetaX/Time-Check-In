extends Node

# warning-ignore:unused_signal
signal UpdateLanguange()

var MySaves = {}
var MySettings = {}

func _ready():
	LoadSettings()
# warning-ignore:return_value_discarded
	connect("UpdateLanguange",self,"ClearAllData")
	
func ClearAllData():
	GlobalTime.HasCheckin = []
	GlobalTime.HasCheckOut = []

func AddCheckIn(CheckInDate):
	AddMySavesPath(CheckInDate)
	var C = FindEmptyCheckIn(MySaves[CheckInDate["year"]][CheckInDate["month"]][CheckInDate["day"]])
	MySaves[CheckInDate["year"]][CheckInDate["month"]][CheckInDate["day"]]["check_in"+String(C)] = CheckInDate
	SaveToFile()
	
func FindEmptyCheckIn(data):
	var empty = 1
	while data.has("check_in"+String(empty)):
		empty += 1
	return empty
	
func FindLastCheckIn(data):
	var last = 1
	while data.has("check_in"+String(last)):
		last += 1
	last -= 1
	return last
	
func AddCheckOut(CheckOutDate):
	AddMySavesPath(CheckOutDate)
	var L = FindLastCheckIn(MySaves[CheckOutDate["year"]][CheckOutDate["month"]][CheckOutDate["day"]])
	MySaves[CheckOutDate["year"]][CheckOutDate["month"]][CheckOutDate["day"]]["check_out"+String(L)] = CheckOutDate
	SaveToFile()
	
func AddDayOff(DayOffDay):
	AddMySavesPath(DayOffDay)
	MySaves[DayOffDay["year"]][DayOffDay["month"]][DayOffDay["day"]]["report"] = "Day Off"
	SaveToFile()
	GlobalTime.emit_signal("UpdateSpecificDayInfo",DayOffDay["day"],MySaves[DayOffDay["year"]][DayOffDay["month"]][DayOffDay["day"]])

	
func AddHoliday(DayOffDay):
	AddMySavesPath(DayOffDay)
	MySaves[DayOffDay["year"]][DayOffDay["month"]][DayOffDay["day"]]["report"] = "Holiday"
	SaveToFile()
	GlobalTime.emit_signal("UpdateSpecificDayInfo",DayOffDay["day"],MySaves[DayOffDay["year"]][DayOffDay["month"]][DayOffDay["day"]])

func RemoveReport(Date):
	AddMySavesPath(Date)
	if MySaves[Date["year"]][Date["month"]][Date["day"]].has("report"):
		MySaves[Date["year"]][Date["month"]][Date["day"]].erase("report")
	SaveToFile()
	GlobalTime.emit_signal("UpdateSpecificDayInfo",Date["day"],MySaves[Date["year"]][Date["month"]][Date["day"]])

func AddMySavesPath(Date):
	
	if !MySaves.has(Date["year"]):
		MySaves[Date["year"]] = {}
		
	if !MySaves[Date["year"]].has(Date["month"]):
		MySaves[Date["year"]][Date["month"]] = {}
		
	if !MySaves[Date["year"]][Date["month"]].has(Date["day"]):
		MySaves[Date["year"]][Date["month"]][Date["day"]] = {}


func SaveToFile():
	for year in MySaves:
		for month in MySaves[year]:
			var F = File.new()
			F.open("user://SaveFile"+String(year*month)+".sf",File.WRITE)
			F.store_var(MySaves[year][month])
			F.close()

func LoadSpecificFile(Month,Year):
	var Res = null
	var F = File.new()
	if F.file_exists("user://SaveFile"+String(Year*Month)+".sf"):
		F.open("user://SaveFile"+String(Year*Month)+".sf",File.READ)
		Res = F.get_var()
	
	F.close()
	
	if Res != null:
		for x in Res:
			var DateToAdd = {"year":Year,"month":Month,"day":x}
			AddMySavesPath(DateToAdd)
			MySaves[Year][Month][x] = Res[x]
	
	#Find if there are dates checked_out in last days and do checkout on 00:00
	var CurDate = OS.get_datetime()
	if Res != null:
		for x in Res:
			
			if CurDate["year"] > Year || CurDate["month"] > Month || CurDate["day"] > x:
				var CheckIns = 0
# warning-ignore:unused_variable
				var LastCheckIn = 0
				for Day in Res[x]:
					if "check_in" in Day:
						CheckIns += 1
						LastCheckIn = int(Day.replace("check_in",""))
					if "check_out" in Day:
						CheckIns -=1
				if CheckIns > 0:
					var NewCheckOut = {"year":Year,"month":Month,"day":x,"hour":24,"minute":0,"second":0}
					AddCheckOut(NewCheckOut)
	return Res

func SaveSettings():
	var F = File.new()
	F.open("user://Settings.ini",File.WRITE)
	F.store_var(MySettings)
	F.close()
	
	
func AddVarsToSettings(Category,Key,Value):
	if !MySettings.has(Category):
		MySettings[Category] = {}
	MySettings[Category][Key] = Value
	SaveSettings()
	
func RemoveSettingByCategory(Category):
	if MySettings.has(Category):
		MySettings.erase(Category)
	SaveSettings()
	
	
func LoadSettings():
	var F = File.new()
	if !F.file_exists("user://Settings.ini"):
		return
	F.open("user://Settings.ini",File.READ)
	MySettings = F.get_var()
	F.close()
	var Lang = GetValueFromSettingCategory("Languange")
	if Lang != null:
		if Lang.has("lang"):
			#print(Lang["lang"])
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
			print("Languange ",Lang," not supported yet.")
func GetValueFromSettings(Category,Key):
	if !MySettings.has(Category):
		return null
	if !MySaves[Category].has(Key):
		return null
	return MySettings[Category][Key]
	
func GetValueFromSettingCategory(Category):
	if !MySettings.has(Category):
		return null
	return MySettings[Category]
