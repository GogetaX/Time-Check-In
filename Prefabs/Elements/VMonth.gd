extends GridContainer

@onready var MonthSelector = get_parent().get_parent().get_node("TopMenu/CurMonth")

var CalDay = preload("res://Prefabs/Elements/CalDay.tscn")
var CurDateInfo = {}

func _ready():
# warning-ignore:return_value_discarded
	GlobalTime.connect("UpdateSpecificDayInfo", Callable(self, "ShowInfoOnDay"))
	
	
func SyncMonth():
	CurDateInfo = GlobalTime.GetDateInfo(MonthSelector.CurMonth,MonthSelector.CurYear)
	InitWeekDays()
	InitDays()
	
func InitWeekDays():
	var Day = 0
	var S = GlobalSave.GetValueFromSettingCategory("CalendarSettings")
	if S != null:
		if S.has("WeekStartNumber"):
			Day = S["WeekStartNumber"]
			
	for x in get_children():
		if "WeekDay" in x.name:
			Day += 1
			if Day > 7:
				Day = 1
			x.text = GlobalTime.WeekDayToDayName(Day-1)[0]
			
func ShowInfoOnDay(Day,InfoData):
	for x in get_children():
		if str(Day) == x.text:
			x.AddInfo(InfoData) 
	
func InitDays():
	#Free old
	for x in get_children():
		if "EmptyDay" in x.name:
			x.queue_free()
			
		if "CurDay" in x.name:
			x.queue_free()
		
	
	var CurDate = Time.get_datetime_dict_from_system()
	var OffsetDay = 0
	var S = GlobalSave.GetValueFromSettingCategory("CalendarSettings")
	if S != null:
		if S.has("WeekStartNumber"):
			OffsetDay = S["WeekStartNumber"]
	var StartFrom = CurDateInfo["start_from"]
	var PlusSeven = 0
	if StartFrom <= OffsetDay:
		PlusSeven = 7
		
	for x in range(1,CurDateInfo["tot_days"]+StartFrom-OffsetDay+PlusSeven,1):
		var Day = CalDay.instantiate()
		add_child(Day)
		#Day.name = "CurDay"+String(x)
		
		#Day.name = "CurDay"+String(x)
		if x < CurDateInfo["start_from"]-OffsetDay+PlusSeven:
			Day.name = "EmptyDay"+str(x)
			Day.text = " "
		else:
			Day.name = "CurDay"+str(x-PlusSeven+1)
			Day.text = str(x-CurDateInfo["start_from"]+1+OffsetDay-PlusSeven)
		
		if MonthSelector.CurMonth == CurDate["month"] && MonthSelector.CurYear == CurDate["year"]:
			if CurDate["day"] == x-CurDateInfo["start_from"]+1+OffsetDay-PlusSeven:
				Day.Select(true)
				
		#Select Current Day
		if CurDate["year"] == MonthSelector.CurYear:
			if CurDate["month"] == MonthSelector.CurMonth:
				if x-CurDateInfo["start_from"]+1+OffsetDay-PlusSeven == CurDate["day"]:
					Day.SelectTodaysDay()
