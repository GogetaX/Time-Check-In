extends Label

const BASE_COLOR = Color("BCE0FD")
const SELECTED_COLOR = Color("2699FB")

var StartPos = Vector2()
var is_Pressed = false

var ColorStyle = null

signal OnToggle()

func _ready():
	StartPos = $BG/Toggle.rect_position
	ColorStyle = $BG.get_stylebox("panel")
	ColorStyle.set_bg_color(BASE_COLOR)


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			AnimToggle()

func AnimToggle():
	
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"FinishAnim",[T])
	if !is_Pressed:
		T.interpolate_property($BG/Toggle,"rect_position:x",StartPos.x,$BG.rect_size.x-$BG/Toggle.rect_size.x-5,0.3,Tween.TRANS_SINE,Tween.EASE_OUT)
		T.interpolate_property(ColorStyle,"bg_color",ColorStyle.get_bg_color(),SELECTED_COLOR,0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	else:
		T.interpolate_property($BG/Toggle,"rect_position:x",$BG/Toggle.rect_position.x,5,0.3,Tween.TRANS_SINE,Tween.EASE_OUT)
		T.interpolate_property(ColorStyle,"bg_color",ColorStyle.get_bg_color(),BASE_COLOR,0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	is_Pressed = !is_Pressed
	T.start()
	emit_signal("OnToggle")
	
func FinishAnim(T):
	T.queue_free()
