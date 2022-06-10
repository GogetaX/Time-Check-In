extends TextureRect

export (bool) var Pressed = false setget SetPressed
export (String) var BtnGroup = "" setget SetBtngroup

signal BtnPressed()

func _ready():
	GlobalTime.connect("BtnGroupPressed",self,"GroupPressed")
	SyncPressed()
	
func SetBtngroup(new):
	BtnGroup = new
	
	
func SetPressed(new):
	Pressed = new

func BtnToggled(_pressed):
	Pressed = _pressed
	SyncPressed()

func SyncPressed():
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"TweenFinished",[T])
	if Pressed:
		T.interpolate_property(self,"modulate",modulate,Color(1,1,1,1),0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	else:
		T.interpolate_property(self,"modulate",modulate,Color(1,1,1,0.55),0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	T.start()

func GroupPressed(BtnNode,GroupName):
	if BtnGroup != GroupName: return
	if BtnNode == self && !Pressed:
		BtnToggled(true)
		return
	if BtnNode != self && Pressed:
		BtnToggled(false)
		return
		
		
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			BtnToggled(!Pressed)
			emit_signal("BtnPressed")
			GlobalTime.emit_signal("BtnGroupPressed",self,BtnGroup)
func TweenFinished(T):
	T.queue_free()
