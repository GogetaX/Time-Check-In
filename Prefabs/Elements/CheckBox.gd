extends Label

const BASE_COLOR = Color("BCE0FD")
const SELECTED_COLOR = Color("2699FB")

var StartPos = Vector2()
var is_Pressed = false

var ColorStyle = null

signal OnToggle()

func _ready():
	StartPos = $BG/Toggle.position
	# Assuming $BG is a Panel node; adjust "Panel" if the node type differs
	ColorStyle = get_theme_stylebox("panel", "Panel").duplicate()
	$BG.add_theme_stylebox_override("panel", ColorStyle)
	ColorStyle.set_bg_color(BASE_COLOR)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			$PressTimer.start()
		if !event.pressed && get_global_rect().has_point(event.global_position) && !$PressTimer.is_stopped():
			AnimToggle()

func AnimToggle(emit_signal = true):
	var T = create_tween()
	GlobalTime.SwipeEnabled = false
	T.connect("finished", Callable(self, "FinishAnim").bind(T))
	if !is_Pressed:
		T.tween_property($BG/Toggle, "position:x", $BG.size.x - $BG/Toggle.size.x - 5, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		T.tween_property(ColorStyle, "bg_color", SELECTED_COLOR, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	else:
		T.tween_property($BG/Toggle, "position:x", 5, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		T.tween_property(ColorStyle, "bg_color", BASE_COLOR, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	is_Pressed = !is_Pressed
	if emit_signal:
		OnToggle.emit()

func FinishAnim(_T):
	GlobalTime.SwipeEnabled = true
	# No need to free T; create_tween() handles cleanup automatically
