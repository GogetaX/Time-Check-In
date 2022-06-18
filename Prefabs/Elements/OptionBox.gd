extends MenuButton


func _ready():
	focus_mode = Control.FOCUS_NONE
# warning-ignore:return_value_discarded
	connect("about_to_show",self,"about_to_show")
	
func about_to_show():
	for a in get_children():
		a.submenu_popup_delay = 0
		for b in a.get_item_count():
			if a.get_item_metadata(b) == null:
				a.set_item_metadata(b,a.get_item_text(b))
			a.set_item_text(b,TranslationServer.translate(a.get_item_text(b)))
