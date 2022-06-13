extends Label

var TotalItemInstance = preload("res://Prefabs/Elements/TotalItem.tscn")

onready var VBox = get_parent().get_parent().get_node("Scroll/VBox")

var CurSelectedMonth = {}

func _ready():
# warning-ignore:return_value_discarded
	GlobalTime.connect("BtnGroupPressed",self,"GroupPressed")
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
	
func DisplayElements(_Date):
	#Remove Old Elements
	for x in VBox.get_children():
		x.queue_free()
	
	var Itm = null
	var Info = {}
	var Delay = 0.1
	
	#Period
	Itm = TotalItemInstance.instance()
	VBox.add_child(Itm)
	var minmax = GlobalTime.GetDateInfo(CurSelectedMonth["month"],CurSelectedMonth["year"])["tot_days"]
	Info = {"title":"Period","desc":GlobalTime.GetMonthName(CurSelectedMonth["month"])[1]+", "+String(minmax)+" days"} 
	Itm.ShowItem(Delay,Info)
	Delay += 0.1
	
	#Tot Worked Days
	var DaysInMonth = GlobalSave.LoadSpecificFile(CurSelectedMonth["month"],CurSelectedMonth["year"])
	var TotDays = 0
	Itm = TotalItemInstance.instance()
	VBox.add_child(Itm)
	if DaysInMonth != null:
		for x in DaysInMonth:
			if DaysInMonth[x].has("check_in1"):
				TotDays += 1
	Info = {"title":"Days worked","desc":String(TotDays)+" days"} 
	Itm.ShowItem(Delay,Info)
	Delay += 0.1
	
	#Tot Worked Hours
	Itm = TotalItemInstance.instance()
	VBox.add_child(Itm)
	var SecondsWorked = 0
	if DaysInMonth != null:
		
		for x in DaysInMonth:
			SecondsWorked += GlobalTime.CalcBetweenCheckinsTOSeconds(DaysInMonth[x])
	var is_On_Going = ""
	var CurMonth = OS.get_datetime()
	if CurMonth["month"] == CurSelectedMonth["month"] && CurMonth["year"] == CurSelectedMonth["year"]:
		if GlobalTime.CurTimeMode == GlobalTime.TIME_CHECKED_IN:
			is_On_Going = " + Check-in"
	Info = {"title":"Hours worked","desc":String(SecondsWorked/3600)+" hours"+is_On_Going} 
	Itm.ShowItem(Delay,Info)
	Delay += 0.1
	
	#Tot Earned Money
	var Settings = GlobalSave.GetValueFromSettingCategory("SaloryCalculation")
	if Settings != null:
		if Settings.has("enabled"):
			if Settings["enabled"]:
				Itm = TotalItemInstance.instance()
				VBox.add_child(Itm)
				var Sufix = ""
				if Settings.has("sufix"):
					Sufix = " "+Settings["sufix"]
				Itm.ShowItem(Delay,{"title":"Earned","desc":String(SecondsWorked/3600.0*Settings["salary"])+Sufix+is_On_Going})
				Delay += 0.1
	#Seperator
	Itm = TotalItemInstance.instance()
	VBox.add_child(Itm)
	Itm.ShowItem(Delay,{})
	Delay += 0.1
	
	#Reporting Days off
	TotDays = 0
	Itm = TotalItemInstance.instance()
	VBox.add_child(Itm)
	if DaysInMonth != null:
		for x in DaysInMonth:
			if DaysInMonth[x].has("report"):
				if DaysInMonth[x]["report"] == "Day Off":
					TotDays += 1
	Info = {"title":"Days off","desc":String(TotDays)+" days"} 
	Itm.ShowItem(Delay,Info)
	Delay += 0.1
	
	#Reporting Holidays
	TotDays = 0
	Itm = TotalItemInstance.instance()
	VBox.add_child(Itm)
	if DaysInMonth != null:
		for x in DaysInMonth:
			if DaysInMonth[x].has("report"):
				if DaysInMonth[x]["report"] == "Holiday":
					TotDays += 1
	Info = {"title":"Holidays","desc":String(TotDays)+" days"} 
	Itm.ShowItem(Delay,Info)
	Delay += 0.1

func GroupPressed(BtnNode,_GroupName):
	if BtnNode.name != "Totals": return
	SyncCurrentMonth(CurSelectedMonth)
		
	
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
