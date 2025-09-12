extends Panel

const UnselectedColor = Color.WHITE
const SelectedColor = Color("2699fb")
var is_pressed = false

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
		var Num = int(x.name.replace("Num", ""))
		if Num == WeekNum:
			return x
	return null

func InitWeeks():
	for x in $WeekContainer.get_children():
		var Num = int(x.name.replace("Num", ""))
		x.text = GlobalTime.WeekDayToDayName(Num)[0]
		x.mouse_filter = Control.MOUSE_FILTER_PASS
		x.connect("gui_input", Callable(self, "WeekClick").bind(x))

func WeekClick(event, weekLabel):
	if event is InputEventMouseButton:
		if event.pressed:
			is_pressed = weekLabel
			$PressTimer.start()
		if !event.pressed && is_pressed == weekLabel:
			if is_pressed != null:
				if is_pressed.get_global_rect().has_point(event.global_position) && !$PressTimer.is_stopped():
					is_pressed = null
					SelectWeekLabel(weekLabel)

func LabelToNum(WeekLabel):
	return int(WeekLabel.name.replace("Num", ""))

func SelectWeekLabel(WeekLabel):
	# Unselect all except the chosen label and save the setting
	GlobalSave.AddVarsToSettings("CalendarSettings", "WeekStartNumber", LabelToNum(WeekLabel))
	var T = create_tween()
	for x in $WeekContainer.get_children():
		if x.modulate != UnselectedColor && x != WeekLabel:
			T.tween_property(x, "modulate", UnselectedColor, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		if x == WeekLabel:
			T.tween_property(x, "modulate", SelectedColor, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	T.connect("finished", Callable(self, "FinishedTween").bind(T))

func FinishedTween(_T):
	pass  # No need for manual cleanup in Godot 4.x
