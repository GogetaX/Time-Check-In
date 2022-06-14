extends Button

const COLOR_DISABLED = Color(0.5,0.5,0.5,1)
const COLOR_NORMAL = Color("2699FB")


func _ready():
# warning-ignore:return_value_discarded
	connect("pressed",self,"BtnPressed")
	
	
func BtnPressed():
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"FinishedTween",[T])
	T.interpolate_property(self,"modulate",COLOR_DISABLED,COLOR_NORMAL,0.1,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	T.start()
	
func FinishedTween(T):
	T.queue_free()
