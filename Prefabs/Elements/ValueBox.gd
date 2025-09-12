@tool
extends Label

@export var MinMax: Vector2 = Vector2(0,99999999): set = SetMinMax
@export var InisialValue: float = 35.5: set = SetInisialValue
@export var HasArrows: bool = true: set = SetHasArrows
@export var FrontText: String = "Salary": set = SetFrontText
@export var FontColor: Color = Color("#2699fb"): set = SetFontColor
@export var MinuteIndicator: bool = false: set = SetMinuteIndicator

signal UpdatedVar(NewVar)


var is_Disabled = false

func _ready():
	$LineEdit.visible = false
	$LineEdit.virtual_keyboard_enabled = false
# warning-ignore:return_value_discarded
	$VirtualKeyboardTimer.connect("timeout", Callable(self, "CheckIfVirtualKeyboard"))

func SetMinuteIndicator(new):
	MinuteIndicator = new
	if MinuteIndicator:
		if text.length()==1:
			text = "0"+text
		if text.length()==0:
			text = "00"
			
func GetValue():
	return text
	
func SetFontColor(new):
	FontColor = new
	$Label.set("theme_override_colors/font_color",FontColor)
	
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
	text = str(InisialValue)
	SetMinuteIndicator(MinuteIndicator)
	if Engine.is_editor_hint(): return
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
			await get_tree().idle_frame
			if !$LineEdit.visible:
				GlobalTime.ShowKeypad(self,"OnEntry")
				$LineEdit.grab_focus()
				$LineEdit.placeholder_text = text
				$LineEdit.max_length = str(MinMax.y).length()
				#$LineEdit.align = align
				$LineEdit.visible = true
				$LineEdit.text = ""
				$LineEdit.caret_column = $LineEdit.text.length()
				text = ""
				

func OnEntry(Key):
	match Key:
		"<":
			if $LineEdit.text.length() > 0:
				$LineEdit.text = $LineEdit.text.substr(0,$LineEdit.text.length()-1)
		"ENT","TAP_OUTSIDE":
			$LineEdit.visible = false
			if $LineEdit.text.is_valid_int() || $LineEdit.text.is_valid_float():
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
	$LineEdit.caret_column = $LineEdit.text.length()
	
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
