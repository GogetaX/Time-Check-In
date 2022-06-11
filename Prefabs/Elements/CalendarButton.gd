extends Button

var is_Disabled = false

func _ready():
	disabled = true
	modulate = Color(0.5,0.5,0.5,1)
	is_Disabled = true

func SetDisabled(Disable):
	disabled = Disable
	if is_Disabled && !Disable:
		var T = Tween.new()
		add_child(T)
		T.connect("tween_all_completed",self,"FinishedTween",[T])
		T.interpolate_property(self,"modulate",modulate,Color(1,1,1,1),0.3,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		T.start()
	is_Disabled = Disable
	
	
func FinishedTween(T):
	T.queue_free()
