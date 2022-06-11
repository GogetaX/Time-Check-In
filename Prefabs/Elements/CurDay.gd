extends Label

onready var CurMonth = get_parent().get_parent().get_parent().get_node("TopMenu/CurMonth")


func _ready():
	var CurDate = OS.get_datetime()
# warning-ignore:return_value_discarded
	GlobalTime.connect("SelectDay",self,"SelectedDay")
	text = "Today "+String(CurDate["day"])+" "+GlobalTime.GetMonthName(CurDate["month"])[0]+" "+String(CurDate["year"])
	
func SelectedDay(_DayNode):
	var DayDescription = ""
	var CurDate = OS.get_datetime()
	if CurDate["year"] == GlobalTime.CurSelectedDate["year"] && CurDate["month"] == GlobalTime.CurSelectedDate["month"] && CurDate["day"] == GlobalTime.CurSelectedDate["day"]:
		DayDescription = "Today "
	elif CurDate["year"] == GlobalTime.CurSelectedDate["year"] && CurDate["month"] == GlobalTime.CurSelectedDate["month"] && CurDate["day"] == GlobalTime.CurSelectedDate["day"]-1:
		DayDescription = "Tomorrow "
	elif CurDate["year"] == GlobalTime.CurSelectedDate["year"] && CurDate["month"] == GlobalTime.CurSelectedDate["month"] && CurDate["day"] == GlobalTime.CurSelectedDate["day"]+1:
		DayDescription = "Yesterday "
	elif CurDate["year"] == GlobalTime.CurSelectedDate["year"] && CurDate["month"] == GlobalTime.CurSelectedDate["month"]:
		DayDescription = "This month "
	elif CurDate["year"] == GlobalTime.CurSelectedDate["year"] && CurDate["month"] == GlobalTime.CurSelectedDate["month"]-1:
		DayDescription = "Next month "
	elif CurDate["year"] == GlobalTime.CurSelectedDate["year"] && CurDate["month"] == GlobalTime.CurSelectedDate["month"]+1:
		DayDescription = "Last month "
	elif CurDate["year"] == GlobalTime.CurSelectedDate["year"]:
		DayDescription = "This year"
	elif CurDate["year"] == GlobalTime.CurSelectedDate["year"]-1:
		DayDescription = "Next year"
	elif CurDate["year"] == GlobalTime.CurSelectedDate["year"]+1:
		DayDescription = "Last year"
	
	text = DayDescription+String(GlobalTime.CurSelectedDate["day"])+" "+GlobalTime.GetMonthName(GlobalTime.CurSelectedDate["month"])[0]+" "+String(GlobalTime.CurSelectedDate["year"])
