extends Control

var CurNode = null

func _ready():
# warning-ignore:return_value_discarded
	GlobalTime.connect("ShowOnlyScreen",self,"ShowOnly")
# warning-ignore:return_value_discarded
	GlobalTime.connect("NoAnimShowWindow",self,"NoAnimShowWindow")
# warning-ignore:return_value_discarded
	$SwipeDetector.connect("Swiped",self,"CheckForSwipe")
	HideAll()
	ShowOnly("TimeScreen")
	

func CheckForSwipe(Dir):
	var T = Tween.new()
	add_child(T)
	var NextNode = GetNextNodeToSwipe()
	var PrevNode = GetPrevNodeToSwipe()
# warning-ignore:shadowed_variable
	var CurNode = GetCurNodeToSwipe()

	match Dir:
		"LEFT":
			if NextNode != null:
				FindBtnByScreen(NextNode)
				T.connect("tween_all_completed",self,"FinishedTweenSwipe",[T,CurNode])
				NextNode.rect_position.x = NextNode.rect_size.x
				NextNode.visible = true
				NextNode.rect_scale = Vector2(1,1)
				T.interpolate_property(NextNode,"rect_position:x",NextNode.rect_position.x,0,0.2,Tween.TRANS_LINEAR,Tween.EASE_OUT)
				T.interpolate_property(CurNode,"rect_position:x",CurNode.rect_position.x,-CurNode.rect_size.x,0.2,Tween.TRANS_LINEAR,Tween.EASE_OUT)
			else:
				CurNode.rect_scale = Vector2(1,1)
				T.connect("tween_all_completed",self,"FinishedTweenSwipe",[T,null])
				T.interpolate_property(CurNode,"rect_position:x",0,-100,0.1,Tween.TRANS_LINEAR,Tween.EASE_OUT)
				T.interpolate_property(CurNode,"rect_position:x",-100,0,0.1,Tween.TRANS_CUBIC,Tween.EASE_OUT,0.1)
		"RIGHT":
			
			if PrevNode != null:
				FindBtnByScreen(PrevNode)
				T.connect("tween_all_completed",self,"FinishedTweenSwipe",[T,CurNode])
				PrevNode.rect_position.x = -PrevNode.rect_size.x
				PrevNode.visible = true
				T.interpolate_property(PrevNode,"rect_position:x",PrevNode.rect_position.x,0,0.2,Tween.TRANS_LINEAR,Tween.EASE_OUT)
				T.interpolate_property(CurNode,"rect_position:x",CurNode.rect_position.x,CurNode.rect_size.x,0.2,Tween.TRANS_LINEAR,Tween.EASE_OUT)
			else:
				T.connect("tween_all_completed",self,"FinishedTweenSwipe",[T,null])
				T.interpolate_property(CurNode,"rect_position:x",0,100,0.1,Tween.TRANS_LINEAR,Tween.EASE_OUT)
				T.interpolate_property(CurNode,"rect_position:x",100,0,0.1,Tween.TRANS_CUBIC,Tween.EASE_OUT,0.1)
	T.start()

			
func FindBtnByScreen(ScreenNode):
	for x in $BottomUI/HBoxContainer.get_children():
		if ScreenNode.name == x.name:
			x.BtnToggled(true)
			GlobalTime.emit_signal("BtnGroupPressed",x,x.BtnGroup)
		else:
			x.BtnToggled(false)

func GetNextNodeToSwipe():
	var NextNode = null
	var GOForNext = false
	for x in get_children():
		if "Screen" in x.name && "HourEditorScreen" != x.name:
			if GOForNext:
				NextNode = x
				return NextNode
			if x.visible:
				GOForNext = true
	return NextNode
	
func GetCurNodeToSwipe():
	for x in get_children():
		if "Screen" in x.name && "HourEditorScreen" != x.name:
			if x.visible:
				return x
	return null
	
func GetPrevNodeToSwipe():
	var PrevNode = null
	for x in get_children():
		if "Screen" in x.name && "HourEditorScreen" != x.name:
			if x.visible:
				return PrevNode
			PrevNode = x
		
	return null
	
func FinishedTweenSwipe(T,NodeToReturnBack):
	T.queue_free()
	if NodeToReturnBack == null:
		return
	NodeToReturnBack.visible = false
	NodeToReturnBack.rect_position = Vector2.ZERO
	
func NoAnimShowWindow(WindowName):
	CurNode = GetCurNodeToSwipe()
	for x in get_children():
		if "Screen" in x.name:
			if WindowName == x.name:
				x.visible = true
				if CurNode == null:
					CurNode = x
				else:
					CurNode.visible = false
					CurNode = x
					CurNode.visible = true
			else:
				x.visible = false
			
func HideAll():
	for x in get_children():
		if "Screen" in x.name:
			x.visible = false


func ShowOnly(WindowName):
	FinalizeTweens()
	CurNode = GetCurNodeToSwipe()
	for x in get_children():
		if "Screen" in x.name:
			if WindowName == x.name:
				if CurNode == x:
					return
				x.visible = true
				
				if CurNode != null:
					AnimateWindow(CurNode,false)
				CurNode = x
				AnimateWindow(CurNode,true)
			else:
				pass
				#x.visible = false
				
func FinalizeTweens():
	for x in get_children():
		if x is Tween:
			if x.is_active():
				x.reset_all()
				x.stop_all()
				
func AnimateWindow(WindowNode,In):
	var T = Tween.new()
	add_child(T)
		
	WindowNode.rect_pivot_offset = WindowNode.rect_size / 2
	if In:
		T.connect("tween_all_completed",self,"FinishTween",[T])
		WindowNode.rect_position = Vector2.ZERO
		WindowNode.rect_scale = Vector2(0.5,0.5)
		WindowNode.modulate = Color(1,1,1,0)
		T.interpolate_property(WindowNode,"rect_scale",WindowNode.rect_scale,Vector2(1,1),0.3,Tween.TRANS_SINE,Tween.EASE_OUT)
		T.interpolate_property(WindowNode,"modulate",WindowNode.modulate,Color(1,1,1,1),0.2,Tween.TRANS_SINE,Tween.EASE_OUT)
	else:
		T.connect("tween_all_completed",self,"FinishTweenAndHide",[T,WindowNode])
		T.interpolate_property(WindowNode,"modulate",WindowNode.modulate,Color(1,1,1,0),0.2,Tween.TRANS_SINE,Tween.EASE_OUT)
	T.start()
	
func FinishTween(T):
	T.queue_free()

func FinishTweenAndHide(T,NodeToHide):
	T.queue_free()
	NodeToHide.visible = false
	NodeToHide.modulate = Color(1,1,1,1)
	
func _on_CheckIn_BtnPressed():
	ShowOnly("TimeScreen")

func _on_Calendar_BtnPressed():
	
	ShowOnly("CalendarScreen")


func _on_Totals_BtnPressed():
	ShowOnly("TotalsScreen")


func _on_Settings_BtnPressed():
	ShowOnly("SettingsScreen")

