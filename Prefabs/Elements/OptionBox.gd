extends MenuButton


func _ready():
	focus_mode = Control.FOCUS_NONE
# warning-ignore:return_value_discarded
	connect("about_to_popup", Callable(self, "about_to_popup"))
# warning-ignore:return_value_discarded
	get_popup().connect("modal_closed", Callable(self, "Closed"))

func Closed():
	get_popup().offset_left = 0
	get_popup().offset_right = 0
	get_popup().offset_bottom = 0
	get_popup().offset_top = 0
	get_popup().position = Vector2.ZERO
	
func about_to_popup():
	for a in get_children():
		a.submenu_popup_delay = 0
		for b in a.get_item_count():
			if a.get_item_metadata(b) == null:
				a.set_item_metadata(b,a.get_item_text(b))
			a.set_item_text(b,TranslationServer.translate(a.get_item_text(b)))


func ForceShowOnMouse(Position):
	get_popup().position = Position
	#If too on right, move lil bit left
	var WindowSize = get_viewport_rect().size
	WindowSize.y -= 100
	if get_popup().position.x + get_popup().size.x > WindowSize.x:
		get_popup().position.x = WindowSize.x - get_popup().size.x
		
	if get_popup().position.x < 0:
		get_popup().position.x = 0
		
	if get_popup().position.y + get_popup().size.y > WindowSize.y:
		get_popup().position.y = WindowSize.y - get_popup().size.y
		
	if get_popup().position.y < 0:
		get_popup().position.y = 0
	
	get_popup().show_modal(false)


func _on_Currency_gui_input(event):
	if disabled:
		return
	if event is InputEventMouseButton:
		#print(get_rect().has_point(event.position))
		if event.pressed:
			$PressTimer.start()
		if !event.pressed && get_global_rect().has_point(event.global_position) && !$PressTimer.is_stopped():
			ForceShowOnMouse(event.global_position)
