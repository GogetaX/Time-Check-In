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


func ForceShowOnMouse(Position):
	get_popup().rect_position = Position
	#If too on right, move lil bit left
	var WindowSize = get_viewport_rect().size
	if get_popup().rect_position.x + get_popup().rect_size.x > WindowSize.x:
		get_popup().rect_position.x = WindowSize.x - get_popup().rect_size.x
		
	if get_popup().rect_position.x < 0:
		get_popup().rect_position.x = 0
		
	if get_popup().rect_position.y + get_popup().rect_size.y > WindowSize.y:
		get_popup().rect_position.y = WindowSize.y - get_popup().rect_size.y
		
	if get_popup().rect_position.y < 0:
		get_popup().rect_position.y = 0
	
	get_popup().show_modal(false)
