extends Button


	
func _ready():
# warning-ignore:return_value_discarded
	connect("toggled",self,"BtnToggled")
	SyncPressed()

func BtnToggled(_pressed):
	SyncPressed()

func SyncPressed():
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"TweenFinished",[T])
	if pressed:
		T.interpolate_property(self,"modulate",modulate,Color(1,1,1,1),0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	else:
		T.interpolate_property(self,"modulate",modulate,Color(1,1,1,0.55),0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	T.start()
		
		
func TweenFinished(T):
	T.queue_free()
