extends Panel

const UnselectedColor = Color.white
const SelectedColor = Color("2699fb")


func _ready():
	GetSettings()
	InitWeeks()
	
func GetSettings():
	var S = GlobalSave.GetValueFromSettingCategory("CalendarSettings")
	var WeekNumber = 0
	if S != null:
		if S.has("WeekStartNumber"):
			WeekNumber = S["WeekStartNumber"]
	SelectWeekLabel(FromNumToLabel(WeekNumber))
	
func FromNumToLabel(WeekNum):
	for x in $WeekContainer.get_children():
		var Num = int(x.name.replace("Num",""))
		if Num == WeekNum:
			return x
	return null
	
func InitWeeks():
	for x in $WeekContainer.get_children():
		var Num = int(x.name.replace("Num",""))
		x.text = GlobalTime.WeekDayToDayName(Num)[0]
		x.mouse_filter = Control.MOUSE_FILTER_PASS
		x.connect("gui_input",self,"WeekClick",[x])

func WeekClick(event,weekLabel):
	if event is InputEventMouseButton:
		if event.pressed:
			SelectWeekLabel(weekLabel)

func LabelToNum(WeekLabel):
	return int(WeekLabel.name.replace("Num",""))
	
func SelectWeekLabel(WeekLabel):
	#UnSelect all except
	GlobalSave.AddVarsToSettings("CalendarSettings","WeekStartNumber",LabelToNum(WeekLabel))
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"FinishedTween",[T])
	for x in $WeekContainer.get_children():
		if x.modulate != UnselectedColor && x != WeekLabel:
			T.interpolate_property(x,"modulate",x.modulate,UnselectedColor,0.2,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		if x == WeekLabel:
			T.interpolate_property(x,"modulate",x.modulate,SelectedColor,0.2,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	T.start()
	
func FinishedTween(T):
	T.queue_free()
