extends Panel

var ClickTimer = null
var MousePos = Vector2()
var CurData = {}
var HintShown = false
var MinMaxHeight = Vector2(80,140)
var CurItem = {}
var BGStyle = null

func _ready():
	
	$HBoxContainer/Salary/Report.visible = false
	$EditWorkingHours.visible = false
	$Change.visible = false

func ClearAll():
	for x in $HBoxContainer.get_children():
		if x is Label:
			x.text = ""
			
func AddEmptyDate(date):
	CurData = date
	ClearAll()
	CheckIfToday(date)
	var WeekDayNum = 0
	if date.has("day"):
		$HBoxContainer/Circle/Day.text = String(date["day"])
		WeekDayNum = GlobalTime.GetWeekNumFromDate(date)
		
	$HBoxContainer/Circle/WeekDay.text = GlobalTime.WeekDayToDayName(WeekDayNum)[0]
	$HBoxContainer/CheckIns.text = "No report"
	$HBoxContainer/Salary/Report.visible = true
	GlobalSave.AddReportOptionsToNode($HBoxContainer/Salary/Report)
	
	$HBoxContainer/Salary/Report.get_popup().connect("index_pressed",self,"SelectedReport")
	
func SelectedReport(index):
	var report = ""
	if $HBoxContainer/Salary/Report.visible:
		report = $HBoxContainer/Salary/Report.get_popup().get_item_metadata(index)
	if $Change.visible:
		report = $Change.get_popup().get_item_metadata(index)
	GlobalTime.SelectCurDayList(CurData,CurItem)
	match report:
		"Day off":
			GlobalSave.AddDayOff(CurData)
		"Holiday":
			GlobalSave.AddHoliday(CurData)
		"Work day":
			GlobalSave.RemoveDayComplete(CurData)
			var CheckInDate = CurData.duplicate()
			
			CheckInDate["hour"] = 0
			CheckInDate["minute"] = 0
			CheckInDate["second"] = 0
			var CheckOutDate = CheckInDate.duplicate()
			GlobalSave.AddCheckIn(CheckInDate)
			var S = GlobalSave.GetValueFromSettingCategory("WorkingHours")
			if S == null:
				CheckOutDate["hour"] += 8
			else:
				CheckOutDate["hour"] += S["hours"]
				if S.has("minutes"):
					CheckOutDate["minute"] = S["minutes"]
			GlobalSave.AddCheckOut(CheckOutDate)
			GlobalTime.FillCheckInOutArray(CheckInDate,CheckOutDate)
			GlobalTime.emit_signal("UpdateSpecificDayInfo",CheckOutDate["day"],GlobalSave.MySaves[CheckOutDate["year"]][CheckOutDate["month"]][CheckOutDate["day"]])
			GlobalTime.SyncCurDay(CheckOutDate)
		_:
			print(report, " not added yet.")
	GlobalTime.emit_signal("UpdateList")
	
		
	
func InitInfo(date,data):
	CurData = date
	CurItem = data
	ClearAll()
	BGStyle = get_stylebox("panel").duplicate()
	set("custom_styles/panel",BGStyle)
	
	
	var WeekDayNum = 0
	if date.has("day"):
		data = GlobalTime.FilterChecksIns(data)
		$HBoxContainer/Circle/Day.text = String(date["day"])
		WeekDayNum = GlobalTime.GetWeekNumFromDate(date)
	
	
	var WorkedTime = GlobalTime.CalcHowLongWorked(data)
	var WorkedSeconds = GlobalTime.DateToSeconds(WorkedTime)
	var WorkedDays = 0
	if WorkedTime != null:
		if WorkedTime["hour"] + WorkedTime["minute"] > 0:
			var Minute = String(WorkedTime["minute"])
			if Minute.length() == 1:
				Minute = "0"+Minute
			$HBoxContainer/Time.text = String(WorkedTime["hour"])+":"+Minute
			WorkedDays += 1
	$HBoxContainer/Circle/WeekDay.text = GlobalTime.WeekDayToDayName(WeekDayNum)[0]
	var TotCheckins = GlobalTime.HowManyCheckIns(data)
	if TotCheckins > 0:
		$HBoxContainer/CheckIns.text = String(TotCheckins)
		
	var HowMuch = GlobalTime.HowMuchIEarnedFromSeconds(GlobalTime.DateToSeconds(WorkedTime))
	if HowMuch[0] > 0:
		$HBoxContainer/Salary.text = GlobalTime.FloatToString(HowMuch[0],2)+TranslationServer.translate(HowMuch[1])
		
	if data.has("report"):
		GlobalSave.AddReportOptionsToNode($Change)
		if !$Change.get_popup().is_connected("index_pressed",self,"SelectedReport"):
			$Change.get_popup().connect("index_pressed",self,"SelectedReport")
		$HBoxContainer/CheckIns.text = data["report"]
		$HBoxContainer/Time/Holiday.texture = GlobalSave.ReportToImage(data["report"])
		var C = GlobalTime.GetColorFromReport(data["report"])
		var CircleStyle = $HBoxContainer/Circle.get_stylebox("panel").duplicate()
		CircleStyle.bg_color = C
		$HBoxContainer/Circle.set("custom_styles/panel",CircleStyle)
	
	#Check if this is current day:
	CheckIfToday(date)
		
	if data.has("total_amount"):
		$HBoxContainer/CheckIns.text = "Total"
		$HBoxContainer/Salary.text = GlobalTime.FloatToString(data["total_amount"],2)+TranslationServer.translate(HowMuch[1])
	else:
		SetupBtnPressEvent()
		
	if data.has("worked_seconds"):
		var WorkedTotal = GlobalTime.SecondsToDate(data["worked_seconds"])
		var Minute = String(WorkedTotal["minute"])
		if Minute.length() == 1:
			Minute = "0"+Minute
		$HBoxContainer/Time.text = String((WorkedTotal["day"] * 24)+WorkedTotal["hour"])+":"+Minute
	if data.has("worked_days"):
		$HBoxContainer/Circle/Day.text = String(data["worked_days"])
		$HBoxContainer/Circle/WeekDay.text = "days"
	return {"earned":HowMuch[0],"worked_seconds":WorkedSeconds,"worked_days":WorkedDays}

func CheckIfToday(date):
	var is_today = false
	if date.has("day"):
		var CurDay = OS.get_datetime()
		if CurDay["day"] == date["day"] && CurDay["month"] == date["month"] && CurDay["year"] == date["year"]:
			var CircleStyle = $HBoxContainer/Circle.get_stylebox("panel").duplicate()
			GlobalTime.emit_signal("ScrollToCurrentDay",self)
			CircleStyle.bg_color = GlobalTime.CURRENTDAY_COLOR
			$HBoxContainer/Circle.set("custom_styles/panel",CircleStyle)
			is_today = true
	return is_today
	
func SetupBtnPressEvent():
# warning-ignore:return_value_discarded
	$BG.connect("gui_input",self,"BGPress")
# warning-ignore:return_value_discarded
	$EditWorkingHours.connect("pressed",self,"EditWorkinfHoursPressed")
	ClickTimer = Timer.new()
	add_child(ClickTimer)
	ClickTimer.one_shot = true
	
func EditWorkinfHoursPressed():
	GlobalTime.SelectCurDayList(CurData,CurItem)
	GlobalTime.HourSelectorUI.SyncDate(CurData)
	GlobalTime.emit_signal("ShowOnlyScreen","HourEditorScreen")
	
func BGPress(event):
	if event is InputEventMouseButton:
		if event.pressed:
			MousePos = event.position
			ClickTimer.start(0.5)
		else:
			if MousePos - event.position == Vector2.ZERO:
				if !ClickTimer.is_stopped():
					AnimOpenCloseHints()
					
func AnimOpenCloseHints():
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"FinishTween",[T])
	if !HintShown:
		if !CurItem.has("report"):
			$EditWorkingHours.modulate = Color(1,1,1,0)
			$EditWorkingHours.visible = true
			T.interpolate_property($EditWorkingHours,"modulate",$EditWorkingHours.modulate,Color(1,1,1,1),0.2,Tween.TRANS_LINEAR,Tween.EASE_IN)
		else:
			$Change.modulate = Color(1,1,1,0)
			$Change.visible = true
			T.interpolate_property($Change,"modulate",$Change.modulate,Color(1,1,1,1),0.2,Tween.TRANS_LINEAR,Tween.EASE_IN)
		
		T.interpolate_property(BGStyle,"bg_color:a",0,1,0.2,Tween.TRANS_LINEAR,Tween.EASE_IN)
		T.interpolate_property(self,"rect_min_size:y",MinMaxHeight.x,MinMaxHeight.y,0.2,Tween.TRANS_LINEAR,Tween.EASE_IN)
		
	else:
		if !CurItem.has("report"):
			$EditWorkingHours.modulate = Color(1,1,1,1)
			T.interpolate_property($EditWorkingHours,"modulate",$EditWorkingHours.modulate,Color(1,1,1,0),0.2,Tween.TRANS_LINEAR,Tween.EASE_IN)
		else:
			$Change.modulate = Color(1,1,1,1)
			T.interpolate_property($Change,"modulate",$Change.modulate,Color(1,1,1,0),0.2,Tween.TRANS_LINEAR,Tween.EASE_IN)
		T.interpolate_property(self,"rect_min_size:y",MinMaxHeight.y,MinMaxHeight.x,0.2,Tween.TRANS_LINEAR,Tween.EASE_IN)
		T.interpolate_property(BGStyle,"bg_color:a",1,0,0.2,Tween.TRANS_LINEAR,Tween.EASE_IN)
	T.start()
	HintShown = !HintShown

func FinishTween(T):
	if $EditWorkingHours.modulate == Color(1,1,1,0):
		$EditWorkingHours.visible = false
	if $Change.modulate == Color(1,1,1,0):
		$Change.visible = false
	T.queue_free()


func _on_VisibilityEnabler2D_viewport_entered(_viewport):
	modulate = Color(1,1,1,1)
	$BG.visible = true


func _on_VisibilityEnabler2D_viewport_exited(_viewport):
	modulate = Color(1,1,1,0)
	$BG.visible = false
