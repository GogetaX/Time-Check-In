tool
extends Label

export (float) var InisialValue = 35.5 setget SetInisialValue
export (Vector2) var MinMax = Vector2(0,300.0) setget SetMinMax
export (bool) var HasArrows = true setget SetHasArrows
export (String) var FrontText = "Salary" setget SetFrontText


signal UpdatedVar(NewVar)


var is_Disabled = false
var CanCloseKeyboard = false

func _ready():
	$LineEdit.visible = false
# warning-ignore:return_value_discarded
	$VirtualKeyboardTimer.connect("timeout",self,"CheckIfVirtualKeyboard")
	
		
func SetFrontText(new):
	FrontText = new
	$Label.text = FrontText
	
func SetHasArrows(new):
	HasArrows = new
	$UpBtn.visible = HasArrows
	$DownBtn.visible = HasArrows
	
func SetMinMax(new):
	MinMax = new
	
func SetInisialValue(new):
	InisialValue = new
	if InisialValue > MinMax.y:
		InisialValue = MinMax.y 
	elif InisialValue < MinMax.x:
		InisialValue = MinMax.x
	text = String(InisialValue)
	if Engine.editor_hint: return
	emit_signal("UpdatedVar",InisialValue)

func Disable(setDisabled):
	is_Disabled = setDisabled
	if is_Disabled:
		modulate = Color(0.2,0.2,0.2,0.5)
	else:
		modulate = Color(1,1,1,1)
	$DownBtn.disabled = setDisabled
	$UpBtn.disabled = setDisabled


func _gui_input(event):
	if is_Disabled: return
	if event is InputEventMouseButton:
		if event.pressed:
			if !$LineEdit.visible:
				$LineEdit.placeholder_text = String(InisialValue)
				$LineEdit.text = ""
				$LineEdit.visible = true
				$LineEdit.grab_focus()
				self_modulate = Color(1,1,1,0)
				$LineEdit.caret_position = 0
				$LineEdit.select_all()
				match OS.get_name():
					"iOS","Android":
						CanCloseKeyboard = false
						OS.show_virtual_keyboard("")
						$VirtualKeyboardTimer.start()
						
func _on_DownBtn_pressed():
	var val = InisialValue
	val -= 0.5
	if val < MinMax.x:
		val = MinMax.x
	SetInisialValue(val)

func CheckIfVirtualKeyboard():
	if OS.get_name() == "Windows":
		CanCloseKeyboard = true
		var Val = float($LineEdit.text)
		if Val != 0:
			SetInisialValue(Val)
		self_modulate = Color(1,1,1,1)
		$LineEdit.visible = false
		$VirtualKeyboardTimer.stop()
		return
		
	if OS.get_virtual_keyboard_height()>0:
		CanCloseKeyboard = true
		
	if OS.get_virtual_keyboard_height() <= 0 && CanCloseKeyboard:
		$LineEdit.visible = false
		var Val = float($LineEdit.text)
		if Val != 0:
			SetInisialValue(Val)
			
		self_modulate = Color(1,1,1,1)
		
		$VirtualKeyboardTimer.stop()
	
func _on_UpBtn_pressed():
	var val = InisialValue
	val += 0.5
	if val > MinMax.y:
		val = MinMax.y
	SetInisialValue(val)


func _on_LineEdit_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed && $LineEdit.visible:
			CheckIfVirtualKeyboard()
