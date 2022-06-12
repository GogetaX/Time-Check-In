extends MenuButton


func _ready():
	focus_mode = Control.FOCUS_NONE
	connect("about_to_show",self,"about_to_show")
	
func about_to_show():
	for a in get_children():
		a.popup_exclusive = true
		a.hide_on_state_item_selection = true
