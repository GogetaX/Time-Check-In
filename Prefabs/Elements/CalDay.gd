extends Label

var NormalColor = Color("2699fb")
var InfoColor = Color.purple


var is_Selected = false
var CurDayInfo = {}
var MultiSelectEnabled = false

func _ready():
	Select(false)
	$CurrentDay.visible = false
	mouse_filter = Control.MOUSE_FILTER_PASS
# warning-ignore:return_value_discarded
	GlobalTime.connect("SelectDay",self,"AnimateSelectedDay")
# warning-ignore:return_value_discarded
	GlobalTime.connect("MultiSelect",self,"MultiSelect")
# warning-ignore:return_value_discarded
	connect("gui_input",self,"DaySelect")
	
func MultiSelect(Enabled):
	MultiSelectEnabled = Enabled
	

func AddInfo(DayInfo):
	var UpdateInfo = false
	
	if is_Selected:
		UpdateInfo = true
	CurDayInfo = DayInfo
	if !DayInfo.empty():
		if DayInfo.has("check_in1"):
			add_color_override("font_color",InfoColor)
		elif DayInfo.has("report"):
			match DayInfo["report"]:
				"Day Off":
					add_color_override("font_color",GlobalTime.DAY_OFF_COLOR)
				"Holiday":
					add_color_override("font_color",GlobalTime.HOLIDAY_COLOR)
				_:
					print("Report Uknown: ")
					print(DayInfo)
		else:
			print("Week day unknown!")
			print(DayInfo)
	else:
		add_color_override("font_color",NormalColor)
		
	if UpdateInfo:
		if !MultiSelectEnabled:
			GlobalTime.SelectCurDate(self,CurDayInfo)
	
func Select(SelectIt):
	is_Selected = SelectIt
	$Selected.visible = SelectIt

func DaySelect(event):
	if text == " ":return
	if event is InputEventMouseButton:
		if event.pressed:
			if !MultiSelectEnabled:
				GlobalTime.SelectCurDate(self,CurDayInfo)
			else:
				GlobalTime.MultiSelectDate(self)
			
func SelectTodaysDay():
	$CurrentDay.visible = true
	
func AnimateSelectedDay(DayNode):
	if is_Selected && DayNode != self:
		AnimateSelected(false)
		return
	if !is_Selected && DayNode == self:
		AnimateSelected(true)
		return

func AnimateCantSelect():
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"FinishAnim",[T])
	$Selected.modulate = Color(1,0,0,1)
	$Selected.visible = true
	T.interpolate_property($Selected,"modulate",$Selected.modulate,Color(1,1,1,1),0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	T.start()
	
func AnimateSelected(AnimIn):
	if !AnimIn && !$Selected.visible:
		return
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"FinishAnim",[T])
	is_Selected = AnimIn
	if AnimIn:
		$Selected.modulate = Color(1,1,1,0)
		$Selected.visible = true
		T.interpolate_property($Selected,"modulate",$Selected.modulate,Color(1,1,1,1),0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	else:
		T.interpolate_property($Selected,"modulate",$Selected.modulate,Color(1,1,1,0),0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	T.start()

func FinishAnim(T):
	T.queue_free()
	if !is_Selected:
		$Selected.visible = false
