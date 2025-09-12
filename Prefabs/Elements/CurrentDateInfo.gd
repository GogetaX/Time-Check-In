extends VBoxContainer

var DayInfo = preload("res://Prefabs/Elements/DayInfo.tscn")
var MultiSelectNode = null

func _ready():
# warning-ignore:return_value_discarded
	GlobalTime.connect("SelectDay", Callable(self, "SelectedDate"))
# warning-ignore:return_value_discarded
	GlobalTime.connect("MultiSelectedDate", Callable(self, "MultiSelectedDate"))
# warning-ignore:return_value_discarded
	GlobalTime.connect("MultiSelect", Callable(self, "EnableMultiSelect"))
	
func RemoveAllDays():
	for x in get_children():
		if "DayInfo" in x.name:
			x.queue_free()

func GetSelected():
	var VMonth = get_parent().get_parent().get_node("VMonth")
	for x in VMonth.get_children():
		if "CurDay" in x.name:
			if x.is_Selected:
				return x
	return null
		
func EnableMultiSelect(Enabled):
	RemoveAllDays()
	if Enabled:
		MultiSelectNode = DayInfo.instantiate()
		add_child(MultiSelectNode)
		MultiSelectNode.MultiSelect(GetSelected())
	else:
		if MultiSelectNode != null:
			MultiSelectNode.ReleaseAllSelected()
			MultiSelectNode.queue_free()
			MultiSelectNode = null
	
	
func MultiSelectedDate(DateNode):
	MultiSelectNode.MultiSelect(DateNode)
	
func SelectedDate(_DayButton):
	RemoveAllDays()
	var Day = null
	if GlobalTime.CurSelectedDate["info"].is_empty():
		Day = DayInfo.instantiate()
		add_child(Day)
	else:
		Day = DayInfo.instantiate()
		add_child(Day)
		Day.SetInfo(GlobalTime.CurSelectedDate["info"])

