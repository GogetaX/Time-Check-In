extends Panel

var CurInfo = {}

func _ready():
	modulate = Color(1, 1, 1, 0)
	$Timer.connect("timeout", Callable(self, "DelayStart"))
	var p_bar = get_node_or_null("ProgressBar")
	if p_bar != null:
		p_bar.visible = false

func ShowOvertime(Delay, Info):
	for x in get_children():
		if x is Label:
			x.set_message_translation(false)
	
	if Delay > 0.0:
		$Timer.start(Delay)
	else:
		modulate = Color(1, 1, 1, 1)
	
	if Info.is_empty():
		for x in get_children():
			if x is Label:
				x.text = ""
	
	if Info.has("title"):
		$Title.text = TranslationServer.translate(Info["title"])
	
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

func ShowItem(Delay, Info):
	CurInfo = Info
	$Title.set_message_translation(false)
	$Desc.set_message_translation(false)
	if Delay > 0.0:
		$Timer.start(Delay)
	else:
		modulate = Color(1, 1, 1, 1)
	
	if Info.is_empty():
		$Title.text = ""
		$Desc.text = ""
	
	if Info.has("progress_percent"):
		$ProgressBar.visible = true
		$ProgressBar.min_value = 0
		$ProgressBar.max_value = 100.0
		$ProgressBar.value = 0.0
	
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
	var T = create_tween()
	T.connect("finished", Callable(self, "FinishedShowTween"))
	T.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

func FinishedShowTween():
	if CurInfo.has("progress_percent"):
		var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tw.tween_property($ProgressBar, "value", CurInfo["progress_percent"], 0.9)
