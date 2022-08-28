extends Panel

func _ready():
	modulate = Color(1,1,1,0)
# warning-ignore:return_value_discarded
	$Timer.connect("timeout",self,"DelayStart")

func ShowItem(Delay,Info):
	$Title.set_message_translation(false)
	$Desc.set_message_translation(false)
	if Delay >0.0:
		$Timer.start(Delay)
	else:
		modulate = Color(1,1,1,1)
		
	if Info.empty():
		$Title.text = ""
		$Desc.text = ""
		
	if TranslationServer.get_locale() == "he":
		if Info.has("title"):
			$Desc.text = TranslationServer.translate(Info["title"])
		if Info.has("desc"):
			$Title.text = Info["desc"]
	else:
		if Info.has("title"):
			$Title.text = TranslationServer.translate(Info["title"])
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
