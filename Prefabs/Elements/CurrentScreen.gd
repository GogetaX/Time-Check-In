extends Panel

var StartRect = Vector2.ZERO
var CenterPos = Vector2.ZERO
var CurTween = null

func _ready():
	visible = false
	$Icon.visible = false
	$text.visible = false
# warning-ignore:return_value_discarded
	GlobalTime.connect("CurScreenIndicator", Callable(self, "Animate"))
# warning-ignore:return_value_discarded
	GlobalTime.connect("app_loaded", Callable(self, "app_loaded"))
	

func app_loaded():
	StartRect = size
	CenterPos = position
	
func Animate(icon,txt):
	size = StartRect
	position = CenterPos
	$text.text = ""
	$text.size.x = 10
	$text.text = txt
	var size_x = $text.get_minimum_size().x+30+$Icon.size.x
	$Icon.texture = icon
	modulate.a = 0.0
	$Icon.modulate.a = 0.0
	visible = true
	$Icon.visible = true
	$text.modulate.a = 0.0
	$text.visible = true
	position.y += 50
	if CurTween != null:
		if CurTween.is_running():
			CurTween.stop()
			CurTween.kill()
			CurTween = null
	CurTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		
	CurTween.tween_property(self,"modulate:a",1.0,0.1)
	CurTween.parallel().tween_property(self,"position:y",CenterPos.y,0.2)
	CurTween.tween_property($Icon,"modulate:a",1.0,0.3)
	CurTween.tween_property(self,"size:x",size_x,0.3).set_delay(0.3)
	CurTween.parallel().tween_property(self,"position:x",CenterPos.x - (size_x/2.0)+30,0.3).set_delay(0.3)
	CurTween.tween_property($text,"modulate:a",1.0,0.2)
	CurTween.tween_property(self,"modulate:a",0.0,0.5).set_delay(1.1)
