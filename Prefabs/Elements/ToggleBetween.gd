@tool
extends Panel

const SELECTED_COLOR = Color("2699FB")
const TEXT_SELECTED_COLOR = Color(1, 1, 1, 1.0)
const TEXT_UNSELECTED_COLOR = Color(1, 1, 1, 0.2)
var StartPos = Vector2()

@export var LeftText: String = "Left": set = SetLeftText
@export var RightText: String = "Right": set = SetRightText
@export var FontColor: Color = Color(1, 1, 1, 1): set = SetFontColor

var ColorStyle
var LeftSelected = true

signal OnToggle(val)

func SetFontColor(new):
	FontColor = new

func _ready():
	StartPos = $Toggle.position
	ColorStyle = get_theme_stylebox("panel").duplicate()
	add_theme_stylebox_override("panel", ColorStyle)
	ColorStyle.set_bg_color(SELECTED_COLOR)
	AnimToggle(true)
	$LeftToggle.connect("gui_input", Callable(self, "LeftGUIInput"))
	$RightToggle.connect("gui_input", Callable(self, "RightGUIInput"))
	$LeftToggle.set("theme_override_colors/font_color", FontColor)
	$RightToggle.set("theme_override_colors/font_color", FontColor)

func SetLeftText(new):
	LeftText = new
	$LeftToggle.text = LeftText

func SetRightText(new):
	RightText = new
	$RightToggle.text = RightText

func LeftGUIInput(event):
	if LeftSelected:
		return
	if event is InputEventMouseButton:
		if event.pressed:
			$PressTimer.start()
		if !event.pressed && $LeftToggle.get_global_rect().has_point(event.global_position) && !$PressTimer.is_stopped():
			LeftSelected = true
			AnimToggle(true)
			emit_signal("OnToggle", LeftSelected)

func RightGUIInput(event):
	if !LeftSelected:
		return
	if event is InputEventMouseButton:
		if event.pressed:
			$PressTimer.start()
		if !event.pressed && $RightToggle.get_global_rect().has_point(event.global_position) && !$PressTimer.is_stopped():
			LeftSelected = false
			AnimToggle(true)
			emit_signal("OnToggle", LeftSelected)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			$PressTimer.start()
		if !event.pressed && get_global_rect().has_point(event.global_position) && !$PressTimer.is_stopped():
			AnimToggle()

func AnimToggle(update = false):
	if Engine.is_editor_hint():
		return
	var T = create_tween()
	GlobalTime.SwipeEnabled = false
	T.connect("finished", Callable(self, "FinishAnim").bind(T))
	if !update:
		LeftSelected = !LeftSelected
	if !LeftSelected:
		T.tween_property($Toggle, "position:x", size.x - $Toggle.size.x - 5, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		T.tween_property($LeftToggle, "self_modulate", TEXT_UNSELECTED_COLOR, 0.3).from(TEXT_SELECTED_COLOR).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		T.tween_property($RightToggle, "self_modulate", TEXT_SELECTED_COLOR, 0.3).from(TEXT_UNSELECTED_COLOR).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	else:
		T.tween_property($Toggle, "position:x", 5, 0.3).from($Toggle.position.x).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		T.tween_property($RightToggle, "self_modulate", TEXT_UNSELECTED_COLOR, 0.3).from(TEXT_SELECTED_COLOR).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		T.tween_property($LeftToggle, "self_modulate", TEXT_SELECTED_COLOR, 0.3).from(TEXT_UNSELECTED_COLOR).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	if !update:
		emit_signal("OnToggle", LeftSelected)

func FinishAnim(_T):
	GlobalTime.SwipeEnabled = true
