extends Label

var InislaPos = Vector2()


func _ready():
	$Next.valign = valign
	$Next.visible = false
	
func AnimNext(txt):
	$Next.valign = valign
	$Next.text = txt
	yield(get_tree(),"idle_frame")
	$Next.rect_position = InislaPos
	$Next.rect_position.y -= $Next.rect_size.y
	$Next.self_modulate = Color(1,1,1,0)
	
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"FinishedNext",[T])
	T.interpolate_property($Next,"self_modulate",$Next.self_modulate,Color(1,1,1,1),0.2,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	T.interpolate_property(self,"rect_position:y",rect_position.y,rect_position.y+$Next.rect_size.y,0.2,Tween.TRANS_LINEAR,Tween.EASE_IN)
	T.interpolate_property(self,"self_modulate",Color(1,1,1,1),Color(1,1,1,0),0.2,Tween.TRANS_LINEAR,Tween.EASE_IN)
	T.start()

func FinishedNext(T):
	T.queue_free()
	text = $Next.text
	$Next.visible = false
	self_modulate = Color(1,1,1,1)
	rect_position = InislaPos
