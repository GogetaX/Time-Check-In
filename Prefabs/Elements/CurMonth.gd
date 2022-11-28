extends Label

onready var VMonth = get_parent().get_parent().get_node("Calendar/VMonth")
onready var Calendar = get_parent().get_parent().get_node("Calendar")

var CurMonth = 0
var CurYear = 0
var MultiSelectActive = false setget SetMultiSelect

func _ready():
# warning-ignore:return_value_discarded
	GlobalTime.connect("ReloadCurrentDate",self,"ReloadCurrentDate")
# warning-ignore:return_value_discarded
	GlobalTime.connect("MultiSelect",self,"MultiSelect")
	var Date = OS.get_datetime()
	CurMonth = Date["month"]
	CurYear = Date["year"]
	GlobalTime.CurSelectedDate["day"] = Date["day"]
	GlobalTime.CurSelectedDate["month"] = CurMonth
	GlobalTime.CurSelectedDate["year"] = CurYear
	GlobalTime.TempCurMonth = CurMonth
	GlobalTime.TempCurYear = CurYear
	DisplayMonth(CurMonth,CurYear)
	InitButtons()
	SyncDateButtons()

func SetMultiSelect(new):
	GlobalTime.emit_signal("MultiSelect",new)

func MultiSelect(new):
	MultiSelectActive = new
	SyncTools()
	
func ReloadCurrentDate():
	GetDataFromFile()
	
	
func DisplayMonth(MonthNum,Year):
	text = GlobalTime.GetMonthName(MonthNum)[1]+" "+String(Year)
	SyncTools()
	

func InitButtons():
	for x in get_children():
		if x is Button:
			x.focus_mode = Control.FOCUS_NONE
			x.connect("pressed",self,"MonthPressed",[x])


func MonthPressed(BtnNode):
	SetMultiSelect(false)
	
	var ThisDate = OS.get_datetime()
	if BtnNode is String:
		match BtnNode:
			"This month":
				GlobalTime.CurSelectedDate["day"] = ThisDate["day"]
				CurMonth = ThisDate["month"]
				CurYear = ThisDate["year"]
			_:
				print("CurMonth.gd->MonthPressed() unknown MonthType: ",BtnNode)
	else:
		match BtnNode.name:
			"NextMonth":
				CurMonth += 1
				if CurMonth > 12:
					CurYear += 1
					CurMonth = 1
			"PrevMonth":
				CurMonth -= 1
				if CurMonth <= 0:
					CurYear -= 1
					CurMonth = 12
			"NextYear":
				CurYear += 1
			"PrevYear":
				CurYear -= 1
	GlobalTime.TempCurMonth = CurMonth
	GlobalTime.TempCurYear = CurYear
	
	SyncDateButtons()
	if !BtnNode is String:
		var T = Tween.new()
		add_child(T)
		T.connect("tween_all_completed",self,"FinishedTween",[T])
		if !BtnNode.is_Disabled:
			T.interpolate_property(BtnNode,"modulate",Color(0.5,0.5,0.5,1),Color(1,1,1,1),0.3,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		else:
			T.interpolate_property(BtnNode,"modulate",Color(1,1,1,1),Color(0.5,0.5,0.5,1),0.3,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		T.start()
	
	
	DisplayMonth(CurMonth,CurYear)
	VMonth.SyncMonth()
	get_parent().UpdateList()
	
	GetDataFromFile()
	
func GetDataFromFile():
	var DataFromFile = GlobalSave.LoadSpecificFile(CurMonth,CurYear)
	#GlobalSave.AddMySavesPath({"year":CurYear,"month":CurMonth,"day":})
	
	#Sync if has Info
	if DataFromFile != null:
		for x in DataFromFile:
			VMonth.ShowInfoOnDay(x,DataFromFile[x])
			
	#GlobalTime.emit_signal("SelectDay",
	
func SyncDateButtons():
	var PrevMonth = GlobalTime.HasPrevMonth(CurMonth,CurYear)
	var NextMonth = GlobalTime.HasNextMonth(CurMonth,CurYear)
	var PrevYear = GlobalTime.HasPrevYear(CurMonth,CurYear)
	var NextYear = GlobalTime.HasNextYear(CurMonth,CurYear)
	if PrevMonth == null:
		$PrevMonth.SetDisabled(true)
	else:
		$PrevMonth.SetDisabled(false)
		
	if NextMonth == null:
		$NextMonth.SetDisabled(true)
	else:
		$NextMonth.SetDisabled(false)
		
	if PrevYear == null:
		$PrevYear.SetDisabled(true)
	else:
		$PrevYear.SetDisabled(false)
		
	if NextYear == null:
		$NextYear.SetDisabled(true)
	else:
		$NextYear.SetDisabled(false)
	

func SyncTools():
	var Tool = get_parent().get_node("Tools")
	var ToolList = []
	
	if !MultiSelectActive:
		var ThisDay = OS.get_datetime()
		if CurMonth != ThisDay["month"] || CurYear != ThisDay["year"]:
			ToolList.append(["This month","res://Assets/Icons/Today.png"])
		if Calendar.visible:
			ToolList.append(["Multi-select","res://Assets/Icons/choice.png"])
	else:
		ToolList.append(["Cancel selection","res://Assets/Icons/choice.png",GlobalTime.MULTISELECT_COLOR])
	Tool.ShowTools(ToolList,self,"BtnPressed")
	
func BtnPressed(BtnName):
	match BtnName:
		"This month":
			MonthPressed(BtnName)
		"Multi-select":
			SetMultiSelect(true)
			SyncTools()
		"Cancel selection":
			SetMultiSelect(false)
			SyncTools()
	
func FinishedTween(T):
	T.queue_free()


func _on_Calendar_visibility_changed():
	SyncTools()
