tool
extends Panel

const SELECTED_COLOR = Color("2699FB")
const TEXT_SELECTED_COLOR = Color.white
const TEXT_UNSELECTED_COLOR = Color("bce0fd")
var StartPos = Vector2()



export (String) var LeftText = "Left" setget SetLeftText
export (String) var RightText = "Right" setget SetRightText

var ColorStyle
var LeftSelected = true

signal OnToggle(val)


func _ready():
	StartPos = $Toggle.rect_position
	ColorStyle = get_stylebox("panel").duplicate()
	add_stylebox_override("panel",ColorStyle)
	ColorStyle.set_bg_color(SELECTED_COLOR)
	AnimToggle(true)
# warning-ignore:return_value_discarded
	$LeftToggle.connect("gui_input",self,"LeftGUIInput")
# warning-ignore:return_value_discarded
	$RightToggle.connect("gui_input",self,"RightGUIInput")
	
func SetLeftText(new):
	LeftText = new
	$LeftToggle.text = LeftText

func SetRightText(new):
	RightText = new
	$RightToggle.text = RightText
	
func LeftGUIInput(event):
	if event is InputEventMouseButton:
		if event.pressed:
			LeftSelected = true
			AnimToggle(true)
			emit_signal("OnToggle",LeftSelected)
			
func RightGUIInput(event):
	if event is InputEventMouseButton:
		if event.pressed:
			LeftSelected = false
			AnimToggle(true)
			emit_signal("OnToggle",LeftSelected)
	
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			AnimToggle()
			
func AnimToggle(update = false):
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"FinishAnim",[T])
	if !update:
		LeftSelected = !LeftSelected
	if !LeftSelected:
		T.interpolate_property($Toggle,"rect_position:x",StartPos.x,rect_size.x-$Toggle.rect_size.x-5,0.3,Tween.TRANS_SINE,Tween.EASE_OUT)
		T.interpolate_property($LeftToggle,"self_modulate",TEXT_SELECTED_COLOR,TEXT_UNSELECTED_COLOR,0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		T.interpolate_property($RightToggle,"self_modulate",TEXT_UNSELECTED_COLOR,TEXT_SELECTED_COLOR,0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	else:
		T.interpolate_property($Toggle,"rect_position:x",$Toggle.rect_position.x,5,0.3,Tween.TRANS_SINE,Tween.EASE_OUT)
		T.interpolate_property($RightToggle,"self_modulate",TEXT_SELECTED_COLOR,TEXT_UNSELECTED_COLOR,0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		T.interpolate_property($LeftToggle,"self_modulate",TEXT_UNSELECTED_COLOR,TEXT_SELECTED_COLOR,0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	
	T.start()
	if !update:
		emit_signal("OnToggle",LeftSelected)
	
func FinishAnim(T):
	T.queue_free()
