extends Label

var TotalItemInstance = preload("res://Prefabs/Elements/TotalItem.tscn")
var TotalItemOvertimeInstance = preload("res://Prefabs/Elements/OvertimeTotalItem.tscn")
var StepTime = 0.05

onready var VBox = get_parent().get_parent().get_node("Scroll/VBox")
onready var TotEarned = get_parent().get_parent().get_node("TotEarned")

var CurSelectedMonth = {}

func _ready():
# warning-ignore:return_value_discarded
	GlobalTime.connect("BtnGroupPressed",self,"GroupPressed")
	CurSelectedMonth = OS.get_datetime()
	InitMonthButtons()
	SyncButtons(CurSelectedMonth)
	#SyncCurrentMonth(CurSelectedMonth)

func InitMonthButtons():
	for x in VBox.get_children():
		x.queue_free()
		
	for x in get_children():
		if x is Button:
			x.focus_mode = Control.FOCUS_NONE
			x.connect("pressed",self,"MonthBtnPressed",[x])

func MonthBtnPressed(BtnNode):
	if BtnNode is Button:
		AnimateButton(BtnNode)
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
	elif BtnNode is String:
		match BtnNode:
			"This month":
				CurSelectedMonth = OS.get_datetime()
			"Last month":
				CurSelectedMonth = OS.get_datetime()
				MonthBtnPressed($PrevMonth)
				return
			"Salary simulator":
				GlobalTime.emit_signal("ShowOnlyScreen","SalarySimulatorScreen")
				return
			_:
				print("Eror TotalCurMonth.gd->MonthBtnPressed() String unknown: ",BtnNode)
				return
	else:
		print("Eror TotalCurMonth.gd->MonthBtnPressed() ButtonType unknown: ",BtnNode)
	
	SyncButtons(CurSelectedMonth)
		
	
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
	
	#CXheck if Next Month exist
	if !GlobalTime.HasNextMonth(Date["month"],Date["year"]):
		DisableNextMonth = true
	if !GlobalTime.HasPrevMonth(Date["month"],Date["year"]):
		DisablePrevMonth = true
	
	$NextMonth.SetDisabled(DisableNextMonth)
	$PrevMonth.SetDisabled(DisablePrevMonth)
	
func SyncTools():
	var Tool = get_parent().get_node("Tools")
	var ToolList = []
	var S = GlobalSave.GetValueFromSettingCategory("SalaryDeduction")
	if S != null:
		if S.has("country"):
			if S["country"] == "Israel":
				ToolList.append(["Salary simulator","res://Assets/Icons/sales.png"])
	var ThisDay = OS.get_datetime()
	if CurSelectedMonth["month"] != ThisDay["month"] || CurSelectedMonth["year"] != ThisDay["year"]:
		ToolList.append(["This month","res://Assets/Icons/Today.png"])
	else:
		ToolList.append(["Last month","res://Assets/Icons/Today.png"])
	Tool.ShowTools(ToolList,self,"BtnPressed")
	
func BtnPressed(BtnName):
	MonthBtnPressed(BtnName)
	
func SyncCurrentMonth(Date):
	CurSelectedMonth = Date
	DisplayMonth(Date)
	DisplayElements(Date)
	SyncTools()
	
func RemoveOld():
	for x in VBox.get_children():
		x.queue_free()
		
func DisplayElements(_Date):
	#Remove Old Elements
	RemoveOld()
	var Itm = null
	var Info = {}
	var Delay = 0.1
	
	#Period
	Itm = TotalItemInstance.instance()
	VBox.add_child(Itm)
	var minmax = GlobalTime.GetDateInfo(CurSelectedMonth["month"],CurSelectedMonth["year"])["tot_days"]
	Info = {"title":"total_period","desc":String(minmax)} 
	Itm.ShowItem(Delay,Info)
	Delay += 0.1

	#Tot Worked Days
	var DaysInMonth = GlobalSave.LoadSpecificFile(CurSelectedMonth["month"],CurSelectedMonth["year"])
	var TotDays = 0
	Itm = TotalItemInstance.instance()
	VBox.add_child(Itm)
	if DaysInMonth != null:
		for x in DaysInMonth:
			DaysInMonth[x] = GlobalTime.FilterChecksIns(DaysInMonth[x])
			if DaysInMonth[x].has("check_in1"):
				TotDays += 1
	Info = {"title":"total_worked_days","desc":String(TotDays)} 
	Itm.ShowItem(Delay,Info)
	Delay += 0.1
	
	#Tot Worked Hours
	Itm = TotalItemInstance.instance()
	VBox.add_child(Itm)
	var SecondsWorked = 0
	var SecondsFor125 = 0
	var SecondsFor150 = 0
	if DaysInMonth != null:
		
		for x in DaysInMonth:
			
			var SecondsThisDay = GlobalTime.CalcBetweenCheckinsTOSeconds(DaysInMonth[x])
			var Tot = GlobalTime.GetHowManySecondsOnNosafot(SecondsThisDay)
			SecondsWorked += Tot[0]
			SecondsFor125 += Tot[1]
			SecondsFor150 += Tot[2]
	var CurMonth = OS.get_datetime()
	var dec = ""
	var TotalSecondsWorked = SecondsWorked+SecondsFor125+SecondsFor150
	dec = TranslationServer.translate("total_hours_info").format([GlobalTime.FloatToString(TotalSecondsWorked/3600,1)])
	if CurMonth["month"] == CurSelectedMonth["month"] && CurMonth["year"] == CurSelectedMonth["year"]:
		if GlobalTime.CurTimeMode == GlobalTime.TIME_CHECKED_IN:
			dec = TranslationServer.translate("total_hours_and_going").format([GlobalTime.FloatToString((SecondsWorked+SecondsFor125+SecondsFor150)/3600,1)])
	Info = {"title":"total_hours_worked","desc":dec} 
	Itm.ShowItem(Delay,Info)
	Delay += 0.1
	var Gross = 0
	var Sufix = ""

	#Avrg Working hours per day
	if TotDays >0:
		Itm = TotalItemInstance.instance()
		VBox.add_child(Itm)
		Info = {"title":"total_avrg_hrs_per_day","desc":GlobalTime.FloatToString((TotalSecondsWorked/3600)/TotDays,1) } 
		Itm.ShowItem(Delay,Info)
		Delay += 0.1
	
	#Tot Earned Money
	var Settings = GlobalSave.GetValueFromSettingCategory("SaloryCalculation")
	var Deduction = GlobalSave.GetValueFromSettingCategory("SalaryDeduction")
	TotEarned.ShowItem(0,{})
	if Settings != null && Deduction == null:
		if Settings.has("enabled"):
			if Settings["enabled"]:
				if Settings.has("sufix"):
					Sufix = TranslationServer.translate(Settings["sufix"])
				var TravelAmount = 0
				if Settings.has("bonus"):
					TravelAmount = Settings["bonus"]
				Gross = ((SecondsWorked+SecondsFor125+SecondsFor150)/3600.0)*Settings["salary"]+TravelAmount
				TotEarned.ShowItem(0,{"title":"total_earned","desc":GlobalTime.FloatToString(Gross,2)+Sufix})
	#Seperator
	Itm = TotalItemInstance.instance()
	VBox.add_child(Itm)
	Itm.ShowItem(Delay,{})
	Delay += StepTime
	
	#Deduction
	
	if Deduction != null && (Settings != null && Settings.has("enabled") && Settings["enabled"]):
		if Deduction.has("country"):
			if Deduction["country"] == "Israel":
				var Rest = GlobalTime.IsraelIncomeCalcFromSalary(SecondsWorked,SecondsFor125,SecondsFor150)
				if Rest.has("NosafotHours 125%") || Rest.has("NosafotHours 150%"):
					#ADd Nosafot on top
					#if has 125: #[title,working_title,working_value,earned_title,earned_value
					if Rest.has("NosafotHours 125%"):
						Itm = TotalItemOvertimeInstance.instance()
						VBox.add_child(Itm)
						Itm.ShowOvertime(Delay,{"title":"total_nosafot_125","working_title":"total_hours_worked","working_value":Rest["NosafotHours 125%"],"earned_title":"total_earned","earned_value":Rest["NosafotEarned 125%"]})
						Delay += StepTime
						
						
						Itm = TotalItemInstance.instance()
						VBox.add_child(Itm)
						Itm.ShowItem(Delay,{"title":"","desc":""})
						Delay += StepTime
					if Rest.has("NosafotHours 150%"):
						Itm = TotalItemOvertimeInstance.instance()
						VBox.add_child(Itm)
						Itm.ShowOvertime(Delay,{"title":"total_nosafot_150","working_title":"total_hours_worked","working_value":Rest["NosafotHours 150%"],"earned_title":"total_earned","earned_value":Rest["NosafotEarned 150%"]})
						Delay += StepTime
						

						Itm = TotalItemInstance.instance()
						VBox.add_child(Itm)
						Itm.ShowItem(Delay,{"title":"","desc":""})
						Delay += StepTime
				#Israel

				Itm = TotalItemInstance.instance()
				VBox.add_child(Itm)
				Itm.ShowItem(Delay,{"title":"Israel Deduction","desc":""})
				Delay += StepTime
				for x in Rest:
					if not "Nosafot" in x && not "Net" in x:
						Itm = TotalItemInstance.instance()
						VBox.add_child(Itm)
						var i = String(Rest[x])
						if i.is_valid_integer():
							i = String(i)
						elif i.is_valid_float():
							i = GlobalTime.FloatToString(i,2)
						Itm.ShowItem(Delay,{"title":x,"desc":i})
						Delay += StepTime
					if x == "Net":
						var i = String(Rest[x])
						if i.is_valid_integer():
							i = String(i)
						elif i.is_valid_float():
							i = GlobalTime.FloatToString(i,2)
						TotEarned.ShowItem(0,{"title":x,"desc":i})
				Itm = TotalItemInstance.instance()
				VBox.add_child(Itm)
				Itm.ShowItem(Delay,{})
				Delay += StepTime
				
	
	#Reporting Days off
	TotDays = 0
	Itm = TotalItemInstance.instance()
	VBox.add_child(Itm)
	if DaysInMonth != null:
		for x in DaysInMonth:
			if DaysInMonth[x].has("report"):
				if DaysInMonth[x]["report"] == "Day Off":
					TotDays += 1
	Info = {"title":"total_days_off","desc":String(TotDays)} 
	Itm.ShowItem(Delay,Info)
	Delay += StepTime
	
	#Reporting Holidays
	TotDays = 0
	Itm = TotalItemInstance.instance()
	VBox.add_child(Itm)
	if DaysInMonth != null:
		for x in DaysInMonth:
			if DaysInMonth[x].has("report"):
				if DaysInMonth[x]["report"] == "Holiday":
					TotDays += 1
	Info = {"title":"total_holidays","desc":String(TotDays)} 
	Itm.ShowItem(Delay,Info)
	Delay += StepTime

func GroupPressed(BtnNode,_GroupName):
	if BtnNode == null:
		return
	if BtnNode.name != "TotalsScreen":
		RemoveOld()
		return
	SyncCurrentMonth(CurSelectedMonth)
	
		
	
func DisplayMonth(Date):
	var CurDay = OS.get_datetime()
	var MonthIndicator = ""
	
	if Date["month"] == CurDay["month"] && Date["year"] == CurDay["year"]:
		MonthIndicator = TranslationServer.translate("This month")
	elif Date["month"]+1 == CurDay["month"] && Date["year"] == CurDay["year"]:
		MonthIndicator = TranslationServer.translate("Last month")
	elif Date["month"]-1 == CurDay["month"] && Date["year"] == CurDay["year"]:
		MonthIndicator = TranslationServer.translate("Next month")
	
	if MonthIndicator != "":
		text = TranslationServer.translate("total_title").format([MonthIndicator,GlobalTime.GetMonthName(Date["month"])[1],String(Date["year"])])
	else:
		text = GlobalTime.GetMonthName(Date["month"])[1]+" - "+String(Date["year"])
