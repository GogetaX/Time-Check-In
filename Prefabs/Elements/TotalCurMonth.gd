extends Label

var TotalItemInstance = preload("res://Prefabs/Elements/TotalItem.tscn")

onready var VBox = get_parent().get_parent().get_node("Scroll/VBox")

var CurSelectedMonth = {}

func _ready():
	CurSelectedMonth = OS.get_datetime()
	InitMonthButtons()
	SyncButtons(CurSelectedMonth)
	SyncCurrentMonth(CurSelectedMonth)

func InitMonthButtons():
	for x in VBox.get_children():
		x.queue_free()
		
	for x in get_children():
		if x is Button:
			x.focus_mode = Control.FOCUS_NONE
			x.connect("pressed",self,"MonthBtnPressed",[x])

func MonthBtnPressed(BtnNode):
	match BtnNode.name:
		"NextMonth":
			CurSelectedMonth["month"]+=1
			if CurSelectedMonth["month"]>=13:
				CurSelectedMonth["month"] = 1
				CurSelectedMonth["year"] += 1
		"PrevMonth":
			CurSelectedMonth["month"]-=1
			if CurSelectedMonth["month"]==0:
				CurSelectedMonth["month"] = 12
				CurSelectedMonth["year"] -= 1
	
	SyncButtons(CurSelectedMonth)
	AnimateButton(BtnNode)
	
	SyncCurrentMonth(CurSelectedMonth)

func AnimateButton(BtnNode):
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"FinishedTween",[T])
	if !BtnNode.is_Disabled:
		T.interpolate_property(BtnNode,"modulate",Color(0.5,0.5,0.5,1),Color(1,1,1,1),0.3,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	else:
		T.interpolate_property(BtnNode,"modulate",Color(1,1,1,1),Color(0.5,0.5,0.5,1),0.3,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	T.start()
	
func FinishedTween(T):
	T.queue_free()
	
func SyncButtons(Date):
	var DisableNextMonth = true
	var DisablePrevMonth = true
	var CurMonth = OS.get_datetime()
	if Date["year"] == CurMonth["year"] && Date["month"] == CurMonth["month"]:
		DisableNextMonth = false
	
	var N = GlobalTime.HasNextMonth(Date["month"],Date["year"])
	if N != null:
		if !N.empty():
			DisableNextMonth = false
			
	#Check if has info on prev month
	var D = GlobalTime.HasPrevMonth(Date["month"],Date["year"])
	if D != null:
		if !D.empty():
			DisablePrevMonth = false
	
	$NextMonth.SetDisabled(DisableNextMonth)
	$PrevMonth.SetDisabled(DisablePrevMonth)
	
func SyncCurrentMonth(Date):
	CurSelectedMonth = Date
	DisplayMonth(Date)
	DisplayElements(Date)
	
func DisplayElements(Date):
	#Remove Old Elements
	for x in VBox.get_children():
		x.queue_free()
	
	var MonthInfo = GlobalSave.LoadSpecificFile(Date["month"],Date["year"])
	for x in range(10):
		var Period = TotalItemInstance.instance()
		VBox.add_child(Period)
		var D = {"title":"Under","desc":"Construction!"}
		Period.ShowItem(0.1+(x*0.1),D)
	
func DisplayMonth(Date):
	var CurDay = OS.get_datetime()
	var MonthIndicator = ""
	if Date["month"] == CurDay["month"] && Date["year"] == CurDay["year"]:
		MonthIndicator = "This month, "
	elif Date["month"]+1 == CurDay["month"] && Date["year"] == CurDay["year"]:
		MonthIndicator = "Last month, "
	elif Date["month"]-1 == CurDay["month"] && Date["year"] == CurDay["year"]:
		MonthIndicator = "Next month, "
	
	text = MonthIndicator + GlobalTime.GetMonthName(Date["month"])[1]+" - "+String(Date["year"])
