extends Label


func _ready():
# warning-ignore:return_value_discarded
	GlobalTime.connect("TimeModeChangedTo",self,"ChangedStatus")
	
func ChangedStatus(Status):
	match Status:
		GlobalTime.TIME_IDLE:
			text = "Idle"
		GlobalTime.TIME_CHECKED_IN:
			text = "Checked In"
		GlobalTime.TIME_PAUSED:
			text = "Paused or Checked Out"
