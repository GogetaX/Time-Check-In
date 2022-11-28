extends Label

const BASE_COLOR = Color("BCE0FD")
const SELECTED_COLOR = Color("2699FB")

var StartPos = Vector2()
var is_Pressed = false

var ColorStyle = null

signal OnToggle()

func _ready():
	StartPos = $BG/Toggle.rect_position
	
	
	
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			$PressTimer.start()
		if !event.pressed && get_global_rect().has_point(event.global_position) && !$PressTimer.is_stopped():
			AnimToggle()

func AnimToggle(emit_signal = true):
	if ColorStyle == null:
		ColorStyle = $BG.get_stylebox("panel").duplicate()
		$BG.add_stylebox_override("panel",ColorStyle)
		ColorStyle.set_bg_color(BASE_COLOR)
	var T = Tween.new()
	add_child(T)
	GlobalTime.SwipeEnabled = false
	T.connect("tween_all_completed",self,"FinishAnim",[T])
	if !is_Pressed:
		T.interpolate_property($BG/Toggle,"rect_position:x",StartPos.x,$BG.rect_size.x-$BG/Toggle.rect_size.x-5,0.3,Tween.TRANS_SINE,Tween.EASE_OUT)
		T.interpolate_property(ColorStyle,"bg_color",ColorStyle.get_bg_color(),SELECTED_COLOR,0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	else:
		T.interpolate_property($BG/Toggle,"rect_position:x",$BG/Toggle.rect_position.x,5,0.3,Tween.TRANS_SINE,Tween.EASE_OUT)
		T.interpolate_property(ColorStyle,"bg_color",ColorStyle.get_bg_color(),BASE_COLOR,0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	is_Pressed = !is_Pressed
	T.start()
	if emit_signal:
		emit_signal("OnToggle")
	
func FinishAnim(T):
	GlobalTime.SwipeEnabled = true
	T.queue_free()
