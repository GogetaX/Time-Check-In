extends Control

signal EmitedAnswer(Answer)

func _ready():
	visible = false
	InitAllBtns()
	
func InitAllBtns():
	for a in get_children():
		if a is Panel:
			for b in a.get_children():
				if b is HBoxContainer || b is VBoxContainer:
					for c in b.get_children():
						c.connect("pressed",self,"PressedButton",[c])
						
func ShowModulate(Data):
	InitWindowFromData(Data)
	modulate = Color(1,1,1,0)
	visible = true
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"FinishShow",[T])
	var S = $Background.material
	T.interpolate_property(self,"modulate",modulate,Color(1,1,1,1),0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT,0.2)
	T.interpolate_property(S,"shader_param/blue_amount",0,3.5,0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT,0.5)
	T.start()
	
func InitWindowFromData(Data):
	# {"type": "YesNo","title":"","desc":TranslationServer.translate("Are you sure you want to skip a") % TranslationServer.translate(TodayReport)}
	for x in get_children():
		if "Panel" in x.name:
			if Data["type"]+"Panel" == x.name:
				if Data.has("title"): x.get_node("Title").text = Data["title"]
				if Data.has("Desc"): x.get_node("Desc").text = Data["desc"]
				x.visible = true
			else:
				x.visible = false
	
func HideModulate():
	var T = Tween.new()
	add_child(T)
	var S = $Background.material
	T.connect("tween_all_completed",self,"FinishShowAndHide",[T])
	T.interpolate_property(self,"modulate",modulate,Color(1,1,1,0),0.2,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	T.interpolate_property(S,"shader_param/blue_amount",3.5,0,0.2,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	T.start()
	
func PressedButton(BtnNode):
	emit_signal("EmitedAnswer",BtnNode.name)
	HideModulate()
	
	
func FinishShowAndHide(T):
	T.queue_free()
	visible = false
	
func FinishShow(T):
	T.queue_free()
