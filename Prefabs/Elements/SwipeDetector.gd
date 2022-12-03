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
	if not event is InputEventScreenTouch:
		return
	if !GlobalTime.SwipeEnabled:
		return
	if event.pressed:
		SwipeTimer.start(0.5)
		MousePos = event.position
	if !event.pressed && !SwipeTimer.is_stopped() && SwipeTimer.time_left< 0.45:
		var MPos = (MousePos - event.position).normalized()
		if abs(MousePos.x - event.position.x)<100:
			return
		if abs(MPos.x) + abs(MPos.y) == 1:
			return
		if MPos.x >= 0.8 && abs(MPos.y) < 0.5:
			emit_signal("Swiped",SWIPE_DIR_LEFT)
			return
		if MPos.x <= -0.8 && abs(MPos.y) < 0.5:
			emit_signal("Swiped",SWIPE_DIR_RIGHT)
