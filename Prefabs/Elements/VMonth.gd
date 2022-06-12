extends GridContainer

onready var MonthSelector = get_parent().get_node("TopMenu/CurMonth")

var CalDay = preload("res://Prefabs/Elements/CalDay.tscn")
var CurDateInfo = {}

func _ready():
# warning-ignore:return_value_discarded
	GlobalTime.connect("UpdateSpecificDayInfo",self,"ShowInfoOnDay")
	SyncMonth()

	
func SyncMonth():
	CurDateInfo = GlobalTime.GetDateInfo(MonthSelector.CurMonth,MonthSelector.CurYear)
	InitWeekDays()
	InitDays()
	
func InitWeekDays():
	var Day = 0
	for x in get_children():
		if "WeekDay" in x.name:
			Day += 1
			x.text = GlobalTime.WeekDayToDayName(Day-1)
			
func ShowInfoOnDay(Day,InfoData):
	for x in get_children():
		if int(x.text) == Day:
			x.AddInfo(InfoData) 
	
	
func InitDays():
	#Free old
	for x in get_children():
		if "CurDay" in x.name:
			x.queue_free()
	
	var CurDate = OS.get_datetime()
	for x in range(1,CurDateInfo["tot_days"]+1+CurDateInfo["start_from"],1):
		var Day = CalDay.instance()
		add_child(Day)
		Day.name = "CurDay"+String(x)
		
		#Day.name = "CurDay"+String(x)
		if x < CurDateInfo["start_from"]:
			Day.text = String(x)
			Day.text = " "
		else:
			Day.name = "CurDay"+String(x)
			Day.text = String(x-CurDateInfo["start_from"]+1)
		
		if MonthSelector.CurMonth == CurDate["month"] && MonthSelector.CurYear == CurDate["year"]:
			if CurDate["day"] == x-CurDateInfo["start_from"]+1:
				
				Day.Select(true)
				
		#Select Current Day
		if CurDate["year"] == MonthSelector.CurYear:
			if CurDate["month"] == MonthSelector.CurMonth:
				if x-CurDateInfo["start_from"]+1 == CurDate["day"]:
					Day.SelectTodaysDay()
