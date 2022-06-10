extends MenuButton


func _ready():
	focus_mode = Control.FOCUS_NONE
# warning-ignore:return_value_discarded
	connect("about_to_show",self,"AboutToShow")
	
func AboutToShow():
	for a in get_children():
		a.focus_mode = Control.FOCUS_NONE
		for b in a.get_children():
			if b.has_method("focus_mode"):
				print("here?")
				b.focus_mode = Control.FOCUS_NONE
