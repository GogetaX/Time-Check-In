extends Panel

func InitInfo(date,data):
	for x in $HBoxContainer.get_children():
		if x is Label:
			x.text = ""
	
	var WeekDayNum = 0
	if date.has("day"):
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
		$HBoxContainer/Salary.text = GlobalTime.FloatToString(HowMuch[0],2)+HowMuch[1]
		
	if data.has("report"):
		$HBoxContainer/CheckIns.text = data["report"]
		$HBoxContainer/Salary/Holiday.texture = GlobalSave.ReportToImage(data["report"])
		var C = GlobalTime.GetColorFromReport(data["report"])
		var CircleStyle = $HBoxContainer/Circle.get_stylebox("panel").duplicate()
		CircleStyle.bg_color = C
		$HBoxContainer/Circle.set("custom_styles/panel",CircleStyle)
		
	if data.has("total_amount"):
		$HBoxContainer/CheckIns.text = "Total"
		$HBoxContainer/Salary.text = GlobalTime.FloatToString(data["total_amount"],2)+HowMuch[1]
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
