extends VBoxContainer

var DayInfo = preload("res://Prefabs/Elements/DayInfo.tscn")


func _ready():
# warning-ignore:return_value_discarded
	GlobalTime.connect("SelectDay",self,"SelectedDate")
	
func SelectedDate(_DayButton):
	for x in get_children():
		if "DayInfo" in x.name:
			x.queue_free()
	
	var Day = null
	if GlobalTime.CurSelectedDate["info"].empty():
		Day = DayInfo.instance()
		add_child(Day)
	else:
		Day = DayInfo.instance()
		add_child(Day)
		Day.SetInfo(GlobalTime.CurSelectedDate["info"])
