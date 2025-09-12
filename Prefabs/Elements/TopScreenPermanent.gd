extends Control

func _ready():
	$RightSideLabel.visible = false
	$LeftSideLabel.visible = false
	GlobalTime.connect("BtnGroupPressed", Callable(self, "ChangedUI"))
	GlobalTime.connect("InitSecond", Callable(self, "InitToday"))
	InitToday()

func ChangedUI(BtnNode, _Group):
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
	var Date = Time.get_datetime_dict_from_system()
	var year = Date["year"] % 100  # Get last two digits of the year
	$RightSideLabel.text = "%02d.%02d.%02d" % [Date["day"], Date["month"], year]
	$LeftSideLabel.text = GlobalTime.WeekDayToDayName(Date["weekday"])[1]
	$LeftSideLabel.text += "\n%02d:%02d" % [Date["hour"], Date["minute"]]
