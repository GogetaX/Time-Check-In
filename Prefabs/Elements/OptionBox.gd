extends MenuButton


func _ready():
# warning-ignore:return_value_discarded
	connect("about_to_show",self,"AboutToShow")
	#set_focus_mode(Control.FOCUS_NONE)
	
func AboutToShow():
	for a in get_children():
		a.grab_focus()
		return
