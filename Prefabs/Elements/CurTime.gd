extends Control


func _ready():
	InitSecond()
# warning-ignore:return_value_discarded
	GlobalTime.connect("InitSecond", Callable(self, "InitSecond"))
	
func InitSecond():
	$VBoxContainer/HBoxContainer/CurTime.text = GlobalTime.ShowTime()
	$VBoxContainer/Date.text = GlobalTime.ShowDate()
	$VBoxContainer/HBoxContainer/Seconds.text = GlobalTime.ShowSeconds()
