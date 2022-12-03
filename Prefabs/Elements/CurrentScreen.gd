extends Panel

var StartRect = Vector2.ZERO
var CenterPos = Vector2.ZERO
var CurTween = null

func _ready():
	visible = false
	$Icon.visible = false
	$text.visible = false
# warning-ignore:return_value_discarded
	GlobalTime.connect("CurScreenIndicator",self,"Animate")
# warning-ignore:return_value_discarded
	GlobalTime.connect("app_loaded",self,"app_loaded")
	

func app_loaded():
	StartRect = rect_size
	CenterPos = rect_position
	
func Animate(icon,txt):
	rect_size = StartRect
	rect_position = CenterPos
	$text.text = ""
	$text.rect_size.x = 10
	$text.text = txt
	var size_x = $text.get_minimum_size().x+30+$Icon.rect_size.x
	$Icon.texture = icon
	modulate.a = 0.0
	$Icon.modulate.a = 0.0
	visible = true
	$Icon.visible = true
	$text.modulate.a = 0.0
	$text.visible = true
	rect_position.y += 50
	if CurTween != null:
		if CurTween.is_running():
			CurTween.stop()
			CurTween.kill()
			CurTween = null
	CurTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		
	CurTween.tween_property(self,"modulate:a",1.0,0.1)
	CurTween.parallel().tween_property(self,"rect_position:y",CenterPos.y,0.2)
	CurTween.tween_property($Icon,"modulate:a",1.0,0.3)
	CurTween.tween_property(self,"rect_size:x",size_x,0.3).set_delay(0.3)
	CurTween.parallel().tween_property(self,"rect_position:x",CenterPos.x - (size_x/2.0)+30,0.3).set_delay(0.3)
	CurTween.tween_property($text,"modulate:a",1.0,0.2)
	CurTween.tween_property(self,"modulate:a",0.0,0.5).set_delay(1.1)
