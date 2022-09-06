extends Node

var NonAvoidLetters = "קראטוןםפשדגכעיחלךףזסבהנמצתץ "
var AvoidBuffer = ""

func HebrewTextConvert(txt,WrapLines):
	if TranslationServer.get_locale() != "he":
		return txt
	var res = ""
	var WrapCounter = 0
	for x in range(txt.length()):
		WrapCounter += 1
		match txt[x]:
			")": txt[x] = "("
			"(": txt[x] = ")"
		if WrapLines <= WrapCounter:
			
			if txt[x] == " ":
				WrapCounter = 0
				txt[x] = "\n"
		if !isNotAvoid(txt[x]):
			AvoidBuffer = AvoidBuffer + txt[x]
		else:
			if AvoidBuffer.length() > 0:
				res = AvoidBuffer + res
				AvoidBuffer = ""
			res = txt[x] + res
	if AvoidBuffer.length() > 0:
		res = AvoidBuffer + res
		AvoidBuffer = ""
	var Lines = res.split("\n")
	res = ""
	for x in range(Lines.size()):
		res = Lines[x] + "\n"+res
	AvoidBuffer = ""
	return res 
	
	
func isNotAvoid(txt):
	for x in range(NonAvoidLetters.length()):
		if txt == NonAvoidLetters[x]:
			return true
	return false
