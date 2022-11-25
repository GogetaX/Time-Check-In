tool
extends Label

export (Vector2) var MinMax = Vector2(0,99999999) setget SetMinMax
export (float) var InisialValue = 35.5 setget SetInisialValue
export (bool) var HasArrows = true setget SetHasArrows
export (String) var FrontText = "Salary" setget SetFrontText
export (Color) var FontColor = Color("#2699fb") setget SetFontColor
export (bool) var MinuteIndicator = false setget SetMinuteIndicator

signal UpdatedVar(NewVar)


var is_Disabled = false

func _ready():
	$LineEdit.visible = false
	$LineEdit.virtual_keyboard_enabled = false
# warning-ignore:return_value_discarded
	$VirtualKeyboardTimer.connect("timeout",self,"CheckIfVirtualKeyboard")

func SetMinuteIndicator(new):
	MinuteIndicator = new
	if MinuteIndicator:
		if text.length()==1:
			text = "0"+text
		if text.length()==0:
			text = "00"
			
func SetFontColor(new):
	FontColor = new
	$Label.set("custom_colors/font_color",FontColor)
	
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
	SetMinuteIndicator(MinuteIndicator)
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
			$PressTimer.start()
			
		if !event.pressed && get_global_rect().has_point(event.global_position) && !$PressTimer.is_stopped():
			yield(get_tree(),"idle_frame")
			if !$LineEdit.visible:
				GlobalTime.ShowKeypad(self,"OnEntry")
				$LineEdit.grab_focus()
				$LineEdit.placeholder_text = text
				$LineEdit.max_length = String(MinMax.y).length()
				$LineEdit.align = align
				$LineEdit.visible = true
				$LineEdit.text = ""
				$LineEdit.caret_position = $LineEdit.text.length()
				text = ""
				

func OnEntry(Key):
	match Key:
		"<":
			if $LineEdit.text.length() > 0:
				$LineEdit.text = $LineEdit.text.substr(0,$LineEdit.text.length()-1)
		"ENT","TAP_OUTSIDE":
			$LineEdit.visible = false
			if $LineEdit.text.is_valid_integer() || $LineEdit.text.is_valid_float():
				SetInisialValue($LineEdit.text.to_float())
				return
			else:
				SetInisialValue(InisialValue)
				#text = String(InisialValue)
				#SetMinuteIndicator(MinuteIndicator)
		"CLS":
			$LineEdit.visible = false
			SetInisialValue(InisialValue)
			return
		_:
			$LineEdit.text += Key
	$LineEdit.caret_position = $LineEdit.text.length()
	
func _on_DownBtn_pressed():
	var val = InisialValue
	val -= 0.5
	if val < MinMax.x:
		val = MinMax.x
	SetInisialValue(val)
	
func _on_UpBtn_pressed():
	var val = InisialValue
	val += 0.5
	if val > MinMax.y:
		val = MinMax.y
	SetInisialValue(val)
