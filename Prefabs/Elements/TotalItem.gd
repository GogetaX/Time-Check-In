extends Panel

func _ready():
	modulate = Color(1,1,1,0)
# warning-ignore:return_value_discarded
	$Timer.connect("timeout",self,"DelayStart")

func ShowItem(Delay,Info):
	$Timer.start(Delay)
	if Info.has("title"):
		$Title.text = Info["title"]
	if Info.has("desc"):
		$Desc.text = Info["desc"]

func DelayStart():
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"FinishedShowTween",[T])
	T.interpolate_property(self,"modulate",modulate,Color(1,1,1,1),0.1,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	T.start()

func FinishedShowTween(T):
	T.queue_free()
