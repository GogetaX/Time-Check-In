extends Button

var is_Disabled = false

func _ready():
	disabled = true
	modulate = Color(0.5, 0.5, 0.5, 1)
	is_Disabled = true

func SetDisabled(Disable):
	disabled = Disable
	if is_Disabled and not Disable:
		var T = create_tween()
		T.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		T.connect("finished", Callable(self, "FinishedTween").bind(T))
	is_Disabled = Disable

func FinishedTween(_T):
	pass  # Tween is automatically freed in Godot 4.x
