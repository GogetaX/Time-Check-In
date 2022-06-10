extends Panel

func _ready():
	$CheckInData.visible = false
	$NoInfo.visible = true
	
func SetInfo(Info):
	$NoInfo.visible = false
	$CheckInData.visible = true
	$CheckInData/WorkingHours.text = GlobalTime.GetAllCheckInAndOuts(Info)
	var D = GlobalTime.CalcHowLongWorked(Info)
	$CheckInData/HowLongWorked.text = ShowHowLongWorked(D)
	var SalorySettings = GlobalSave.GetValueFromSettingCategory("SaloryCalculation")
	print(D)
	if SalorySettings.has("enabled"):
		$CheckInData/HowMuchEarned.visible = SalorySettings["enabled"]
		$CheckInData/HowMuchEarned.text = "Earned "+String(GlobalTime.DateToSeconds(D)/3600.0*SalorySettings["salory"])
		if SalorySettings.has("sufix"):
			$CheckInData/HowMuchEarned.text = $CheckInData/HowMuchEarned.text+" "+SalorySettings["sufix"]
func ShowHowLongWorked(Date):
	var LastWord = ""
	var Seconds = Date["hour"]*3600+Date["minute"]*60+Date["second"]
	if Seconds == 1:
		LastWord = "Second"
	elif Seconds < 60:
		LastWord = "Seconds"
	elif Seconds == 60:
		LastWord = "Minute"
	elif Seconds <3600:
		LastWord = "Minutes"
	elif Seconds == 3600:
		LastWord = "Hour"
	
	var Res = "Working Time "
	if Date["hour"]+Date["minute"] == 0:
		Res += String(Date["second"]) + " "+LastWord
	else:
		Res += String(Date["hour"])+":"+String(Date["minute"])+" "+LastWord
		
	return Res
 
