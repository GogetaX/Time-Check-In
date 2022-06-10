extends Label

onready var CurMonth = get_parent().get_parent().get_parent().get_node("TopMenu/CurMonth")


func _ready():
	var CurDate = OS.get_datetime()
# warning-ignore:return_value_discarded
	GlobalTime.connect("SelectDay",self,"SelectedDay")
	text = "Today "+String(CurDate["day"])+" "+GlobalTime.GetMonthName(CurDate["month"])[0]+" "+String(CurDate["year"])
	
func SelectedDay(_DayNode):

	text = String(GlobalTime.CurSelectedDate["day"])+" "+GlobalTime.GetMonthName(GlobalTime.CurSelectedDate["month"])[0]+" "+String(GlobalTime.CurSelectedDate["year"])
