extends Control

var CurNode = null

func _ready():
	GlobalTime.ToolHandler = self
	# warning-ignore:return_value_discarded
	GlobalTime.connect("ShowOnlyScreen", Callable(self, "ShowOnly"))
	# warning-ignore:return_value_discarded
	GlobalTime.connect("NoAnimShowWindow", Callable(self, "NoAnimShowWindow"))
	GlobalTime.emit_signal("app_loaded")
	# warning-ignore:return_value_discarded
	$SwipeDetector.connect("Swiped", Callable(self, "CheckForSwipe"))
	HideAll()
	ShowOnly("TimeScreen")
	ResizeAllForAds()

func ResizeAllForAds():
	var MoveAdsYValue = 0
	$BottomUI.size.y += MoveAdsYValue
	$BottomUI.position.y -= MoveAdsYValue
	$CalendarScreen/Calendar.size.y -= MoveAdsYValue
	$CalendarScreen/List.size.y -= MoveAdsYValue
	$TotalsScreen/Scroll.size.y -= MoveAdsYValue
	$SettingsScreen/ScrollContainer.size.y -= MoveAdsYValue
	$TotalsScreen/TotEarned.position.y -= MoveAdsYValue
	$TopScreenPermanent/CurrentScreen.CenterPos.y -= MoveAdsYValue

func CheckForSwipe(Dir):
	var T = create_tween()
	var NextNode = GetNextNodeToSwipe()
	var PrevNode = GetPrevNodeToSwipe()
	var CurNode = GetCurNodeToSwipe()

	match Dir:
		"LEFT":
			if NextNode != null:
				FindBtnByScreen(NextNode)
				T.connect("finished", Callable(self, "FinishedTweenSwipe").bind(CurNode))
				NextNode.position.x = NextNode.size.x
				NextNode.visible = true
				NextNode.scale = Vector2(1,1)
				T.tween_property(NextNode, "position:x", 0, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
				T.tween_property(CurNode, "position:x", -CurNode.size.x, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
			else:
				CurNode.scale = Vector2(1,1)
				T.connect("finished", Callable(self, "FinishedTweenSwipe").bind(null))
				T.tween_property(CurNode, "position:x", -100, 0.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
				T.tween_property(CurNode, "position:x", 0, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(0.1)
		"RIGHT":
			if PrevNode != null:
				FindBtnByScreen(PrevNode)
				T.connect("finished", Callable(self, "FinishedTweenSwipe").bind(CurNode))
				PrevNode.position.x = -PrevNode.size.x
				PrevNode.visible = true
				T.tween_property(PrevNode, "position:x", 0, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
				T.tween_property(CurNode, "position:x", CurNode.size.x, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
			else:
				T.connect("finished", Callable(self, "FinishedTweenSwipe").bind(null))
				T.tween_property(CurNode, "position:x", 100, 0.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
				T.tween_property(CurNode, "position:x", 0, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(0.1)

func FindBtnByScreen(ScreenNode):
	for x in $BottomUI/HBoxContainer.get_children():
		if ScreenNode.name == x.name:
			x.BtnToggled(true)
			GlobalTime.emit_signal("BtnGroupPressed", x, x.BtnGroup)
		else:
			x.BtnToggled(false)

func GetNextNodeToSwipe():
	var NextNode = null
	var GOForNext = false
	for x in get_children():
		if "Screen" in x.name && "HourEditorScreen" != x.name && "SalarySimulatorScreen" != x.name && not "Permanent" in x.name:
			if GOForNext:
				NextNode = x
				return NextNode
			if x.visible:
				GOForNext = true
	return NextNode

func GetCurNodeToSwipe():
	for x in get_children():
		if "Screen" in x.name && "HourEditorScreen" != x.name && not "Permanent" in x.name && "SalarySimulatorScreen" != x.name:
			if x.visible:
				return x
	return null

func GetPrevNodeToSwipe():
	var PrevNode = null
	for x in get_children():
		if "Screen" in x.name && "HourEditorScreen" != x.name && not "Permanent" in x.name && "SalarySimulatorScreen" != x.name:
			if x.visible:
				return PrevNode
			PrevNode = x
	return null

func FinishedTweenSwipe(NodeToReturnBack):
	if NodeToReturnBack == null:
		return
	NodeToReturnBack.visible = false
	NodeToReturnBack.position = Vector2.ZERO

func NoAnimShowWindow(WindowName):
	CurNode = GetCurNodeToSwipe()
	for x in get_children():
		if "Screen" in x.name && not "Permanent" in x.name:
			if WindowName == x.name:
				x.visible = true
				if CurNode == null:
					CurNode = x
				else:
					CurNode.visible = false
					CurNode = x
					CurNode.visible = true
					FindBtnByScreen(CurNode)
			else:
				x.visible = false

func HideAll():
	for x in get_children():
		if "Screen" in x.name && not "Permanent" in x.name:
			x.visible = false

func ShowOnly(WindowName):
	if WindowName == "TimeScreen":
		$EffectHandler.app_loaded()
	CurNode = GetCurNodeToSwipe()
	for x in get_children():
		if "Screen" in x.name && not "Permanent" in x.name:
			if WindowName == x.name:
				if CurNode == x:
					return
				x.visible = true
				if CurNode != null:
					AnimateWindow(CurNode, false)
				CurNode = x
				AnimateWindow(CurNode, true)
			else:
				pass

func AnimateWindow(WindowNode, In):
	var T = create_tween()
	WindowNode.pivot_offset = WindowNode.size / 2
	if In:
		T.connect("finished", Callable(self, "FinishTween"))
		WindowNode.position = Vector2.ZERO
		WindowNode.scale = Vector2(0.5, 0.5)
		WindowNode.modulate = Color(1, 1, 1, 0)
		T.tween_property(WindowNode, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		T.tween_property(WindowNode, "modulate", Color(1, 1, 1, 1), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		T.connect("finished", Callable(self, "FinishTweenAndHide").bind(WindowNode))
		T.tween_property(WindowNode, "modulate", Color(1, 1, 1, 0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func FinishTween():
	pass

func FinishTweenAndHide(NodeToHide):
	NodeToHide.visible = false
	NodeToHide.modulate = Color(1, 1, 1, 1)

func _on_CheckIn_BtnPressed():
	ShowOnly("TimeScreen")

func _on_Calendar_BtnPressed():
	ShowOnly("CalendarScreen")

func _on_Totals_BtnPressed():
	ShowOnly("TotalsScreen")

func _on_Settings_BtnPressed():
	ShowOnly("SettingsScreen")
