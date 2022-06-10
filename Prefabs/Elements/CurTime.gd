extends Label


func _ready():
	InitSecond()
# warning-ignore:return_value_discarded
	GlobalTime.connect("InitSecond",self,"InitSecond")
	
func InitSecond():
	text = GlobalTime.ShowTime()
	$Date.text = GlobalTime.ShowDate()
	$Seconds.text = GlobalTime.ShowSeconds()
