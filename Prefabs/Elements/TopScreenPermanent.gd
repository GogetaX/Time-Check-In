extends Control


func _ready():
	visible = false
# warning-ignore:return_value_discarded
	GlobalTime.connect("BtnGroupPressed",self,"ChangedUI")
# warning-ignore:return_value_discarded
	GlobalTime.connect("InitSecond",self,"InitToday")
	InitToday()
	
func ChangedUI(BtnNode,_Group):
	match BtnNode.name:
		"TimeScreen":
			visible = false
		_:
			visible = true

func InitToday():
	var Date = OS.get_datetime()
	$RightSideLabel.text = String(Date["day"])+"."+String(Date["month"])+"."+String(Date["year"])
	$LeftSideLabel.text = GlobalTime.WeekDayToDayName(Date["weekday"])[1]
	$LeftSideLabel.text += " "+FilterNumber(Date["hour"])+":"+FilterNumber(Date["minute"])+":"+FilterNumber(Date["second"])

func FilterNumber(Num):
	if Num < 10:
		return "0"+String(Num)
	return String(Num)
