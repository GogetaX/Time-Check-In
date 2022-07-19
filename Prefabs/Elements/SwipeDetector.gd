extends Node

const SWIPE_DIR_LEFT = "LEFT"
const SWIPE_DIR_RIGHT = "RIGHT"

var SwipeTimer = null
var MousePos = Vector2()

signal Swiped(Dir)

func _ready():
	SwipeTimer = Timer.new()
	add_child(SwipeTimer)
	SwipeTimer.one_shot = true
	
func _input(event):
	if get_parent().get_node("HourEditorScreen").visible:
		return
	if not event is InputEventScreenTouch:
		return
	if event.pressed:
		SwipeTimer.start(0.5)
		MousePos = event.position
	if !event.pressed && !SwipeTimer.is_stopped():
		var MPos = (MousePos - event.position).normalized()
		if abs(MPos.x) + abs(MPos.y) == 1:
			return
		if MPos.x >= 0.98 && abs(MPos.y) < 0.2:
			emit_signal("Swiped",SWIPE_DIR_LEFT)
			return
		if MPos.x <= -0.98 && abs(MPos.y) < 0.2:
			emit_signal("Swiped",SWIPE_DIR_RIGHT)
