@tool
extends Label

@export var CharsPeerLine: int = 30: set = SetCharsPeerLine
@export var hebrewText = "": set = SetHebrewText





func SetCharsPeerLine(new):
	CharsPeerLine = new
	
func SetHebrewText(txt):
	set_message_translation(false)
	hebrewText = txt
	if TranslationServer.get_locale() == "he":
		hebrewText = GlobalHebrew.HebrewTextConvert(TranslationServer.translate(txt),CharsPeerLine)
		if align == ALIGN_LEFT:
			align = ALIGN_RIGHT

	text = hebrewText


