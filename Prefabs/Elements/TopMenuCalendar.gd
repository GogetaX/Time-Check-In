extends Panel

const StepSpd = 0.03
var ScrollToPos = null
var ScreenSize = Vector2()
var FastLoad = false

@onready var ListScroll = get_parent().get_node("List/Scroll")

func _ready():
	ClearAll()
# warning-ignore:return_value_discarded
	GlobalTime.connect("BtnGroupPressed", Callable(self, "SyncMenu"))
# warning-ignore:return_value_discarded
	GlobalTime.connect("UpdateList", Callable(self, "FastListUpdate"))
# warning-ignore:return_value_discarded
	GlobalTime.connect("ScrollToCurrentDay", Callable(self, "ScrollToCurrentDay"))
	
	LoadCalendarSwitch()

func ClearAll():
	for x in get_parent().get_node("List/Scroll/VBox").get_children():
		if x.name != "Columns":
			x.queue_free()
	
func ScrollToCurrentDay(ListNode):
	if FastLoad:
		return
	await get_tree().idle_frame
	
	ScrollToPos = ListNode
	if ScrollToPos.global_position.y-400 < 260:
		return
	ScreenSize = get_viewport_rect().size
	var T = Tween.new()
	add_child(T)
	var EndPoint = (ScrollToPos.global_position.y*1.3+(ScrollToPos.size.y)-550)
	T.connect("tween_all_completed", Callable(self, "FinishedShow").bind(T))
	T.interpolate_property(ListScroll,"scroll_vertical",0,EndPoint,0.3,Tween.TRANS_QUAD,Tween.EASE_IN_OUT,0.2)
	T.start()
	
func FastListUpdate():
	if $ToggleBetween.LeftSelected:
		return
	GenerateList(true)
	
func UpdateList():
	if $ToggleBetween.LeftSelected:
		return
	GenerateList()
	
func SyncMenu(Btn,_Group):
	if Btn == null:
		return
	if Btn.name == "CalendarScreen":
		var Calendar = get_parent().get_node("Calendar")
		var List = get_parent().get_node("List")
		if $ToggleBetween.LeftSelected:
			get_parent().get_node("Calendar/VMonth").SyncMonth()
			$CurMonth.GetDataFromFile()
			Calendar.visible = true
			List.visible = false
		else:
			GenerateList()
			Calendar.visible = false
			List.visible = true
	else:
		RemoveOld()
			
func _on_ToggleBetween_OnToggle(val):
	GlobalSave.AddVarsToSettings("CalendarSettings","Calendar_Switch",val)
	AnimToggle(val)
	if val:
		get_parent().get_node("Calendar/VMonth").SyncMonth()
		$CurMonth.GetDataFromFile()


func LoadCalendarSwitch():
	var S = GlobalSave.GetValueFromSettingCategory("CalendarSettings")
	var LeftSwitch = true
	if S != null:
		if S.has("Calendar_Switch"):
			LeftSwitch = S["Calendar_Switch"]
	
	$ToggleBetween.LeftSelected = LeftSwitch
	$ToggleBetween.AnimToggle(true)
	
func RemoveOld():
	var List = get_parent().get_node("List/Scroll/VBox")
	for x in List.get_children():
		if x.name != "Columns":
			x.queue_free()
			
func AnimToggle(LeftShow):
	var Calendar = get_parent().get_node("Calendar")
	var List = get_parent().get_node("List")
	var MaxYPos = size.y
	var MaxXPos = size.x 
	var T = Tween.new()
	add_child(T)
	
	if LeftShow:
		Calendar.visible = true
		Calendar.position = Vector2(Calendar.position.x-Calendar.size.x,MaxYPos)
		List.position = Vector2(0,MaxYPos)
		T.interpolate_property(Calendar,"position",Calendar.position,Vector2(0,MaxYPos),0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		T.interpolate_property(List,"position",List.position,Vector2(MaxXPos,MaxYPos),0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		T.connect("tween_all_completed", Callable(self, "FinishedTween").bind(T,List))
	else:
		List.visible = true
		Calendar.position = Vector2(0,MaxYPos)
		List.position = Vector2(MaxXPos,MaxYPos)
		T.interpolate_property(List,"position",List.position,Vector2(0,MaxYPos),0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		T.interpolate_property(Calendar,"position",Calendar.position,Vector2(-MaxXPos,MaxYPos),0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		T.connect("tween_all_completed", Callable(self, "FinishedTween").bind(T,Calendar))
		GenerateList()
	T.start()


func GenerateList(fast = false):
	FastLoad = fast
	if !fast: 
		ListScroll.scroll_vertical = 0
	var List = get_parent().get_node("List/Scroll/VBox")
	#Remove old
	RemoveOld()
	var MonthSelector = get_node("CurMonth")
	var DataFromFile = GlobalSave.LoadSpecificFile(MonthSelector.CurMonth,MonthSelector.CurYear)
	var ItmInstance = load("res://Prefabs/Elements/ListItem.tscn")
	var TotAmount = 0
	var WorkedSeconds = 0
	var WorkedDays = 0
	var T
	if !fast:
		T = Tween.new()
		add_child(T)
		T.connect("tween_all_completed", Callable(self, "FinishedShow").bind(T))
	var tot = GlobalTime.HowManyDaysInMonth({"year":MonthSelector.CurYear,"month":MonthSelector.CurMonth})
	if DataFromFile == null:
		DataFromFile = {}
	for x in range(1,tot+1):
		if DataFromFile.has(x) && !DataFromFile[x].is_empty():
			var itm = ItmInstance.instantiate()
			List.add_child(itm)
			if !fast:
				itm.modulate = Color(1,1,1,0)
				T.interpolate_property(itm,"modulate",itm.modulate,Color(1,1,1,1),0.2,Tween.TRANS_LINEAR,Tween.EASE_IN)
			var date = {"year":MonthSelector.CurYear,"month":MonthSelector.CurMonth,"day":x}
			var i = itm.InitInfo(date,DataFromFile[x])
			TotAmount += i["earned"]
			WorkedSeconds += i["worked_seconds"]
			WorkedDays += i["worked_days"]
		else:
			var itm = ItmInstance.instantiate()
			List.add_child(itm)
			if !fast:
				itm.modulate = Color(1,1,1,0)
				T.interpolate_property(itm,"modulate",itm.modulate,Color(1,1,1,1),0.2,Tween.TRANS_LINEAR,Tween.EASE_IN)
			var date = {"year":MonthSelector.CurYear,"month":MonthSelector.CurMonth,"day":x}
			itm.AddEmptyDate(date)
	
	#Total Earned/Hours
	var itm = get_parent().get_node("List/TotalItem")
	if !fast:
		itm.modulate = Color(1,1,1,0)
		T.interpolate_property(itm,"modulate",itm.modulate,Color(1,1,1,1),0.2,Tween.TRANS_LINEAR,Tween.EASE_IN,0)
	itm.InitInfo({"year":MonthSelector.CurYear,"month":MonthSelector.CurMonth},{"total_amount":TotAmount,"worked_seconds":WorkedSeconds,"worked_days":WorkedDays})
	if !fast:
		T.start()

func FinishedShow(T):
	T.queue_free()
	
func FinishedTween(T,HideNode):
	T.queue_free()
	HideNode.visible = false
