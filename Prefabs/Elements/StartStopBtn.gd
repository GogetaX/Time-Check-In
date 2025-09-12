extends Button

var is_Toggled = false
var BGColor = Color("7FC4FD")
var OrangeColor = Color("#ff9e26fb")
var DontFlip = false

signal Toggled()

func _ready():
	$IdleText.modulate = Color(1,1,1,1)
	$StartText.modulate = Color(1,1,1,0)
	connect("pressed", Callable(self, "BtnPressed"))

func ForceToggle(is_Pressed):
	if is_Toggled == is_Pressed:
		return
	is_Toggled = is_Pressed
	BtnPressed(true)

func BtnPressed(skip_toggle = false):
	if DontFlip:
		DontFlip = false
		return
	if not skip_toggle:
		is_Toggled = not is_Toggled
	var T = create_tween()
	T.connect("finished", Callable(self, "FinishedTween").bind(skip_toggle))
	pivot_offset = size / 2
	$IdleText.pivot_offset = $IdleText.size / 2
	$StartText.pivot_offset = $IdleText.size / 2
	var NormalStyle = get_theme_stylebox("disabled")
	disabled = true
	if is_Toggled:
		$IdleText.modulate = Color(1,1,1,1)
		$StartText.modulate = Color(1,1,1,0)
		T.tween_property($IdleText, "modulate", Color(1,1,1,0), 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		T.tween_property($StartText, "modulate", Color(1,1,1,1), 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		T.tween_property($StartText, "scale:x", -1, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		T.tween_property(self, "scale:x", -1, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		T.tween_property(NormalStyle, "bg_color", OrangeColor, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	else:
		T.tween_property(NormalStyle, "bg_color", BGColor, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		$IdleText.modulate = Color(1,1,1,0)
		$StartText.modulate = Color(1,1,1,1)
		T.tween_property($IdleText, "modulate", Color(1,1,1,1), 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		T.tween_property($StartText, "modulate", Color(1,1,1,0), 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		T.tween_property(self, "scale:x", 1, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)

func FinishedTween(skip_toggle):
	disabled = false
	if not skip_toggle:
		Toggled.emit()
