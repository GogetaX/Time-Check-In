extends Label


func _ready():
# warning-ignore:return_value_discarded
	GlobalTime.connect("TimeModeChangedTo",self,"ChangedStatus")
	
	
func ChangedStatus(Status):
	match Status:
		GlobalTime.TIME_IDLE:
			text = ""
		GlobalTime.TIME_CHECKED_IN:
			text = TranslationServer.translate("Checked_In")
		GlobalTime.TIME_PAUSED:
			text = TranslationServer.translate("Checked_Out")
