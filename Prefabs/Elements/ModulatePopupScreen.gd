extends Control

var CurrentlyOpenNode = null
#To use the popup:
#var PopupData = {"type": "YesNo","Title":"","Desc":TranslationServer.translate("are_you_sure_to_skip") % TranslationServer.translate(TodayReport)}
#var Answer = yield(GlobalTime.ShowPopup(PopupData),"completed")

#match Answer:
	#"NoBtn":
	#	pass
	#"YesBtn":
	#	pass

signal EmitedAnswer(Answer)

func _ready():
	GlobalTime.SwipeEnabled = false
	visible = false
	InitAllBtns()
	
func InitAllBtns():
	for a in get_children():
		if a is Panel:
			for b in a.get_children():
				if b is HBoxContainer || b is VBoxContainer:
					for c in b.get_children():
						c.focus_mode = Control.FOCUS_NONE
						c.connect("pressed",self,"PressedButton",[c])
						
func ShowModulate(Data):
	InitWindowFromData(Data)
	visible = true
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"FinishShow",[T])
	var S = $Background.material
	S.set("shader_param/blur_amount",0)
	T.interpolate_property(S,"shader_param/blur_amount",0,3.5,0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	for x in get_children():
		if "Panel" in x.name:
			if x.visible:
				x.set("custom_styles/panel",GlobalTheme.LoadResource("res://Prefabs/Styles/ModulatePopupScreen.tres"))
				CurrentlyOpenNode = x
				x.modulate = Color(1,1,1,0)
				T.interpolate_property(x,"modulate",x.modulate,Color(1,1,1,1),0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT,0.3)
	
	T.start()
	
func InitWindowFromData(Data):
	for x in get_children():
		if "Panel" in x.name:
			if Data["type"]+"Panel" == x.name:
				#if Data.has("Title"): x.get_node("Title").text = Data["Title"]
				for d in x.get_children():
					if Data.has(d.name):
						if x.get_node(d.name).has_method("SetHebrewText"):
							x.get_node(d.name).hebrewText = Data[d.name]
						else:
							x.get_node(d.name).text = Data[d.name]
							
						if x.name == "okPanel":
							if "Desc" in d.name:
								AdjustPanelByTextSize("okPanel",Data[d.name])
					
				#if Data.has("Rich"):
					#x.get_node("Rich").bbcode_text = Data["Rich"]
				x.visible = true
			else:
				x.visible = false

func AdjustPanelByTextSize(PanelName,txt):
	var PSize = 0
	if txt.length() >60:
		PSize = txt.length()
	get_node(PanelName).rect_position.y -= PSize
	get_node(PanelName).rect_size.y += PSize
	
func HideModulate():
	var T = Tween.new()
	add_child(T)
	var S = $Background.material
	T.connect("tween_all_completed",self,"FinishShowAndHide",[T])
	T.interpolate_property(S,"shader_param/blur_amount",3.5,0,0.2,Tween.TRANS_LINEAR,Tween.EASE_OUT,0.3)
	for x in get_children():
		if "Panel" in x.name:
			if x.visible:
				T.interpolate_property(x,"modulate",modulate,Color(1,1,1,0),0.2,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	
	T.start()
	
func PressedButton(BtnNode):
	emit_signal("EmitedAnswer",BtnNode.name)
	HideModulate()
	
	
func FinishShowAndHide(T):
	T.queue_free()
	visible = false
	GlobalTime.SwipeEnabled = true
	queue_free()
	
func FinishShow(T):
	T.queue_free()


func _on_Background_gui_input(event):
	if CurrentlyOpenNode == null:
		return
	if event is InputEventMouseButton:
		if event.pressed:
			if CurrentlyOpenNode.get_node("BtnContainer").get_child_count()==1:
				PressedButton(CurrentlyOpenNode.get_node("BtnContainer").get_child(0))
			if CurrentlyOpenNode.get_node("BtnContainer").get_node_or_null("CloseBtn"):
				PressedButton(CurrentlyOpenNode.get_node("BtnContainer").get_node("CloseBtn"))
