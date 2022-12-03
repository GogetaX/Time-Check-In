extends Control


func _ready():
	$RightSideLabel.visible = false
	$LeftSideLabel.visible = false
# warning-ignore:return_value_discarded
	GlobalTime.connect("BtnGroupPressed",self,"ChangedUI")
# warning-ignore:return_value_discarded
	GlobalTime.connect("InitSecond",self,"InitToday")
	InitToday()
	
func ChangedUI(BtnNode,_Group):
	if BtnNode == null:
		return
	match BtnNode.name:
		"TimeScreen":
			$RightSideLabel.visible = false
			$LeftSideLabel.visible = false
		_:
			$RightSideLabel.visible = true
			$LeftSideLabel.visible = true

func InitToday():
	var Date = OS.get_datetime()
	$RightSideLabel.text = String(Date["day"])+"."+String(Date["month"])+"."+String(Date["year"]).substr(2,2)
	$LeftSideLabel.text = GlobalTime.WeekDayToDayName(Date["weekday"])[1]
	$LeftSideLabel.text += "\n"+FilterNumber(Date["hour"])+":"+FilterNumber(Date["minute"])

func FilterNumber(Num):
	if Num < 10:
		return "0"+String(Num)
	return String(Num)
