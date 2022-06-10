extends Node

var MySaves = {}
var MySettings = {}

func _ready():
	LoadSettings()

func AddCheckIn(CheckInDate):
	if !MySaves.has(CheckInDate["year"]):
		MySaves[CheckInDate["year"]] = {}
		
	if !MySaves[CheckInDate["year"]].has(CheckInDate["month"]):
		MySaves[CheckInDate["year"]][CheckInDate["month"]] = {}
		
	if !MySaves[CheckInDate["year"]][CheckInDate["month"]].has(CheckInDate["day"]):
		MySaves[CheckInDate["year"]][CheckInDate["month"]][CheckInDate["day"]] = {}
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
	if !MySaves.has(CheckOutDate["year"]):
		MySaves[CheckOutDate["year"]] = {}
		
	if !MySaves[CheckOutDate["year"]].has(CheckOutDate["month"]):
		MySaves[CheckOutDate["year"]][CheckOutDate["month"]] = {}
		
	if !MySaves[CheckOutDate["year"]][CheckOutDate["month"]].has(CheckOutDate["day"]):
		MySaves[CheckOutDate["year"]][CheckOutDate["month"]][CheckOutDate["day"]] = {}
	var L = FindLastCheckIn(MySaves[CheckOutDate["year"]][CheckOutDate["month"]][CheckOutDate["day"]])
	MySaves[CheckOutDate["year"]][CheckOutDate["month"]][CheckOutDate["day"]]["check_out"+String(L)] = CheckOutDate
	SaveToFile()
	
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
	
func LoadSettings():
	var F = File.new()
	if !F.file_exists("user://Settings.ini"):
		return
	F.open("user://Settings.ini",File.READ)
	MySettings = F.get_var()
	F.close()
	
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
