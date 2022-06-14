extends Button

var is_Toggled = false
var BGColor = Color("7FC4FD")
var OrangeColor = Color("fbff9e26")

signal Toggled()

func _ready():
	$IdleText.modulate = Color(1,1,1,1)
	$StartText.modulate = Color(1,1,1,0)
# warning-ignore:return_value_discarded
	connect("pressed",self,"BtnPressed")
	
func ForceToggle(is_Pressed):
	if is_Toggled == is_Pressed:
		return
	is_Toggled = is_Pressed
	BtnPressed(true)
	
func BtnPressed(skip_toggle = false):
	if !skip_toggle: is_Toggled = !is_Toggled
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"FinishedTween",[T,skip_toggle])
	rect_pivot_offset = rect_size / 2
	$IdleText.rect_pivot_offset = $IdleText.rect_size / 2
	$StartText.rect_pivot_offset = $IdleText.rect_size / 2
	var NormalStyle = get_stylebox("disabled")
	disabled = true
	if is_Toggled:
		$IdleText.modulate = Color(1,1,1,1)
		$StartText.modulate = Color(1,1,1,0)
		T.interpolate_property($IdleText,"modulate",Color(1,1,1,1),Color(1,1,1,0),0.3,Tween.TRANS_LINEAR,Tween.EASE_IN)
		T.interpolate_property($StartText,"modulate",Color(1,1,1,0),Color(1,1,1,1),0.3,Tween.TRANS_LINEAR,Tween.EASE_IN)
		T.interpolate_property($StartText,"rect_scale:x",$StartText.rect_scale.x,-1,0.3,Tween.TRANS_LINEAR,Tween.EASE_IN)
		T.interpolate_property(self,"rect_scale:x",rect_scale.x,-1,0.3,Tween.TRANS_LINEAR,Tween.EASE_IN)
		T.interpolate_property(NormalStyle,"bg_color",BGColor,OrangeColor,0.3,Tween.TRANS_LINEAR,Tween.EASE_IN)
	else:
		T.interpolate_property(NormalStyle,"bg_color",OrangeColor,BGColor,0.3,Tween.TRANS_LINEAR,Tween.EASE_IN)
		$IdleText.modulate = Color(1,1,1,0)
		$StartText.modulate = Color(1,1,1,1)
		T.interpolate_property($IdleText,"modulate",Color(1,1,1,0),Color(1,1,1,1),0.3,Tween.TRANS_LINEAR,Tween.EASE_IN)
		T.interpolate_property($StartText,"modulate",Color(1,1,1,1),Color(1,1,1,0),0.3,Tween.TRANS_LINEAR,Tween.EASE_IN)
		T.interpolate_property(self,"rect_scale:x",rect_scale.x,1,0.3,Tween.TRANS_LINEAR,Tween.EASE_IN)
	T.start()


func FinishedTween(T,skip_toggle):
	disabled = false
	if !skip_toggle:
		emit_signal("Toggled")
	T.queue_free()
