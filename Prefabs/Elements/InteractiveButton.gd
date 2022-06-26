extends Button

const COLOR_DISABLED = Color(0.5,0.5,0.5,1)

var NewCustomColor = Color(1,1,1,1)


func _ready():
# warning-ignore:return_value_discarded
	connect("pressed",self,"BtnPressed")
	NewCustomColor = modulate
	
func BtnPressed():
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"FinishedTween",[T])
	T.interpolate_property(self,"modulate",COLOR_DISABLED,NewCustomColor,0.1,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	T.start()
	
func FinishedTween(T):
	T.queue_free()
