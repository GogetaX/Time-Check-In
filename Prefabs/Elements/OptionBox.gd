extends MenuButton


func _ready():
# warning-ignore:return_value_discarded
	connect("about_to_show",self,"AboutToShow")
	#set_focus_mode(Control.FOCUS_NONE)
	
func AboutToShow():
	for x in get_children():
		x.grab_focus()
