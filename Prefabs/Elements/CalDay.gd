extends Label

var NormalColor = Color("2699fb")
var InfoColor = Color.purple
var DayOffColor = Color.darkgreen
var HolidayColor = Color.chartreuse

var is_Selected = false
var CurDayInfo = {}

func _ready():
	Select(false)
	$CurrentDay.visible = false
	mouse_filter = Control.MOUSE_FILTER_PASS
# warning-ignore:return_value_discarded
	GlobalTime.connect("SelectDay",self,"AnimateSelectedDay")
# warning-ignore:return_value_discarded
	connect("gui_input",self,"DaySelect")
	
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
					add_color_override("font_color",DayOffColor)
				"Holiday":
					add_color_override("font_color",HolidayColor)
				_:
					print("Report Uknown: ")
					print(DayInfo)
		else:
			print("Week day unknown!")
			print(DayInfo)
	else:
		add_color_override("font_color",NormalColor)
		
	if UpdateInfo:
		GlobalTime.SelectCurDate(self,CurDayInfo)
	
func Select(SelectIt):
	is_Selected = SelectIt
	$Selected.visible = SelectIt

func DaySelect(event):
	if text == " ":return
	if event is InputEventMouseButton:
		if event.pressed:
			GlobalTime.SelectCurDate(self,CurDayInfo)
			
func SelectTodaysDay():
	$CurrentDay.visible = true
	
func AnimateSelectedDay(DayNode):
	if is_Selected && DayNode != self:
		AnimateSelected(false)
		return
	if !is_Selected && DayNode == self:
		AnimateSelected(true)
		return
		
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
