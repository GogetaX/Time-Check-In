extends Panel


func _ready():
	modulate = Color(1,1,1,0)
# warning-ignore:return_value_discarded
	$Timer.connect("timeout",self,"DelayStart")


func ShowOvertime(Delay,Info):
	for x in get_children():
		if x is Label:
			x.set_message_translation(false)
	
	if Delay >0.0:
		$Timer.start(Delay)
	else:
		modulate = Color(1,1,1,1)
	
	if Info.empty():
		for x in get_children():
			if x is Label:
				x.text = ""
	
	if Info.has("title"):
		$Title.text = TranslationServer.translate(Info["title"])
	#[title,working_title,working_value,earned_title,earned_value
	if TranslationServer.get_locale() == "he":
		if Info.has("working_title"):
			$WorkingTitle.text = TranslationServer.translate(Info["working_title"])
		if Info.has("working_value"):
			$WorkingValue.text = TranslationServer.translate(Info["working_value"])
		if Info.has("earned_title"):
			$EarnedTitle.text = TranslationServer.translate(Info["earned_title"])
		if Info.has("earned_value"):
			$EarnedValue.text = TranslationServer.translate(Info["earned_value"])
	else:
		if Info.has("working_title"):
			$WorkingValue.text = TranslationServer.translate(Info["working_title"])
		if Info.has("working_value"):
			$WorkingTitle.text = TranslationServer.translate(Info["working_value"])
		if Info.has("earned_title"):
			$EarnedValue.text = TranslationServer.translate(Info["earned_title"])
		if Info.has("earned_value"):
			$EarnedTitle.text = TranslationServer.translate(Info["earned_value"])
		
	
		
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
