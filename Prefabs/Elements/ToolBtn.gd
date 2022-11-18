extends Button

signal ButtonPressed()

func _ready():
# warning-ignore:return_value_discarded
	connect("gui_input",self,"gui_input")
func SetBtnTexture(new):
	$TextureRect.texture = load(new)
	
func gui_input(event):
	if event is InputEventMouseButton:
		#print(get_rect().has_point(event.position))
		if event.pressed:
			$PressTimer.start()
		if !event.pressed && get_global_rect().has_point(event.global_position) && !$PressTimer.is_stopped():
			emit_signal("ButtonPressed")

