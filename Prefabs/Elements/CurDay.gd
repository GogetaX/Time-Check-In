extends Label

onready var CurMonth = get_parent().get_parent().get_parent().get_parent().get_node("TopMenu/CurMonth")


func _ready():
	var CurDate = OS.get_datetime()
# warning-ignore:return_value_discarded
	GlobalTime.connect("SelectDay",self,"SelectedDay")
	text = TranslationServer.translate("Today")+" "+String(CurDate["day"])+" "+GlobalTime.GetMonthName(CurDate["month"])[0]+" "+String(CurDate["year"])
	
func SelectedDay(_DayNode):
	var DayDescription = ""
	var CurDate = OS.get_datetime()
	if CurDate["year"] == GlobalTime.CurSelectedDate["year"] && CurDate["month"] == GlobalTime.CurSelectedDate["month"] && CurDate["day"] == GlobalTime.CurSelectedDate["day"]:
		DayDescription = TranslationServer.translate("Today")+" "
	elif CurDate["year"] == GlobalTime.CurSelectedDate["year"] && CurDate["month"] == GlobalTime.CurSelectedDate["month"] && CurDate["day"] == GlobalTime.CurSelectedDate["day"]-1:
		DayDescription = TranslationServer.translate("Tomorrow")+" "
	elif CurDate["year"] == GlobalTime.CurSelectedDate["year"] && CurDate["month"] == GlobalTime.CurSelectedDate["month"] && CurDate["day"] == GlobalTime.CurSelectedDate["day"]+1:
		DayDescription = TranslationServer.translate("Yesterday")+" "
	elif CurDate["year"] == GlobalTime.CurSelectedDate["year"] && CurDate["month"] == GlobalTime.CurSelectedDate["month"]:
		DayDescription = TranslationServer.translate("This month ")+" "
	elif CurDate["year"] == GlobalTime.CurSelectedDate["year"] && CurDate["month"] == GlobalTime.CurSelectedDate["month"]-1:
		DayDescription = TranslationServer.translate("Next month")+" "
	elif CurDate["year"] == GlobalTime.CurSelectedDate["year"] && CurDate["month"] == GlobalTime.CurSelectedDate["month"]+1:
		DayDescription = TranslationServer.translate("Last month")+" "
	elif CurDate["year"] == GlobalTime.CurSelectedDate["year"]:
		DayDescription = TranslationServer.translate("This year")+" "
	elif CurDate["year"] == GlobalTime.CurSelectedDate["year"]-1:
		DayDescription = TranslationServer.translate("Next year")+" "
	elif CurDate["year"] == GlobalTime.CurSelectedDate["year"]+1:
		DayDescription = TranslationServer.translate("Last year")+" "
	
	text = DayDescription+String(GlobalTime.CurSelectedDate["day"])+" "+GlobalTime.GetMonthName(GlobalTime.CurSelectedDate["month"])[0]+" "+String(GlobalTime.CurSelectedDate["year"])
