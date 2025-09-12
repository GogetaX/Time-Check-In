extends TextureRect

@export var Pressed: bool = false: set = SetPressed
@export var BtnGroup: String = "": set = SetBtngroup
@export var CustomEndColor: Color = Color(1, 1, 1, 0.55): set = SetCustomEndColor

signal BtnPressed()

var is_pressed = false

func _ready():
	var ShaderDup = material.duplicate()
	material = ShaderDup
	GlobalTime.connect("BtnGroupPressed", Callable(self, "GroupPressed"))
	SyncPressed()

func SetCustomEndColor(new):
	CustomEndColor = new

func SetBtngroup(new):
	BtnGroup = new

func SetPressed(new):
	Pressed = new
	SyncPressed()  # Update visual state when Pressed changes

func BtnToggled(_pressed):
	Pressed = _pressed
	SyncPressed()

func SyncPressed():
	var T = create_tween()
	if Pressed:
		T.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	else:
		T.tween_property(self, "modulate", CustomEndColor, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

func GroupPressed(BtnNode, GroupName):
	if BtnGroup != GroupName:
		return
	if BtnNode == self and not Pressed:
		BtnToggled(true)
	elif BtnNode != self and Pressed:
		BtnToggled(false)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			is_pressed = true
		elif is_pressed:
			if BtnGroup == "Menu":
				GlobalTime.emit_signal("CurScreenIndicator", texture, name.replace("Screen", ""))
			BtnToggled(!Pressed)
			BtnPressed.emit()
			GlobalTime.emit_signal("BtnGroupPressed", self, BtnGroup)
			is_pressed = false
