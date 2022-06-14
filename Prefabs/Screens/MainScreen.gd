extends Control

var CurNode = null

func _ready():
# warning-ignore:return_value_discarded
	GlobalTime.connect("ShowOnlyScreen",self,"ShowOnly")
	ShowOnly("TimeScreen")
	
func ShowOnly(WindowName):
	
	for x in get_children():
		if "Screen" in x.name:
			if WindowName == x.name:
				x.visible = true
				if CurNode == null:
					CurNode = x
				else:
					AnimateWindow(CurNode,false)
					CurNode = x
					AnimateWindow(CurNode,true)
			else:
				x.visible = false

func AnimateWindow(WindowNode,In):
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"FinishTween",[T])
	WindowNode.rect_pivot_offset = WindowNode.rect_size / 2
	if In:
		WindowNode.rect_scale = Vector2(0.5,0.5)
		T.interpolate_property(WindowNode,"rect_scale",WindowNode.rect_scale,Vector2(1,1),0.3,Tween.TRANS_ELASTIC,Tween.EASE_OUT)
	T.start()
	
func FinishTween(T):
	T.queue_free()

func _on_CheckIn_BtnPressed():
	ShowOnly("TimeScreen")


func _on_Calendar_BtnPressed():
	$CalendarScreen/TopMenu/CurMonth.GetDataFromFile()
	ShowOnly("CalendarScreen")


func _on_Totals_BtnPressed():
	ShowOnly("TotalsScreen")


func _on_Settings_BtnPressed():
	ShowOnly("SettingsScreen")

