extends Control

var KeyboardHeight = 0
signal OnEntry(BtnText)

func _ready():
	KeyboardHeight = $Panel.position.y
	InitAllBtns()
	$Panel.visible = false
	
func InitAllBtns():
	for x in $Panel/VBoxContainer.get_children():
		for btn in x.get_children():
			if btn is Button:
				btn.focus_mode = Control.FOCUS_NONE
				btn.connect("pressed", Callable(self, "BtnPressed").bind(btn.Cmd))
			
func BtnPressed(btnText):
	emit_signal("OnEntry",btnText)
	
func ShowModulate(exclude_buttons = ""):
	if exclude_buttons != "":
		var btns_to_exclude = exclude_buttons.split(",")
		for a in btns_to_exclude:
			for b in $Panel/VBoxContainer.get_children():
				for c in b.get_children():
					if c is Button:
						if c.text == a:
							c.text = ""
							c.disabled = true
	GlobalTime.SwipeEnabled = false
	var T = Tween.new()
	var ScreenSize = get_viewport_rect().size.y
	$Panel.position.y = ScreenSize
	$Panel.visible = true
	add_child(T)
	T.connect("tween_all_completed", Callable(self, "FinishedTween").bind(T))
	T.interpolate_property($Panel,"position:y",$Panel.position.y,KeyboardHeight,0.2,Tween.TRANS_CIRC,Tween.EASE_OUT)
	T.start()

func HideModulate():
	GlobalTime.SwipeEnabled = true
	var T = Tween.new()
	var ScreenSize = get_viewport_rect().size.y
	add_child(T)
	T.connect("tween_all_completed", Callable(self, "FinishedTweenAndQueue").bind(T))
	T.interpolate_property($Panel,"position:y",$Panel.position.y,ScreenSize,0.2,Tween.TRANS_CIRC,Tween.EASE_IN)
	T.start()
	
func FinishedTween(T):
# warning-ignore:return_value_discarded
	connect("gui_input", Callable(self, "_on_NumpadKeyboard_gui_input"))
	T.queue_free()
	
func FinishedTweenAndQueue(T):
	T.queue_free()
	queue_free()


func _on_NumpadKeyboard_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			emit_signal("OnEntry","TAP_OUTSIDE")
			HideModulate()


func _on_Keypad4_pressed():
	emit_signal("OnEntry","ENT")
	HideModulate()


func _on_ExitBtn_pressed():
	emit_signal("OnEntry","CLS")
	HideModulate()
