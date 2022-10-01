extends Button

var Cmd = ""

func _ready():
	InitIcon()
	
func InitIcon():
	Cmd = text
	match text:
		"<":
			$Icon.texture = load("res://Assets/Icons/backspace.png")
			text = ""
		"ENT":
			$Icon.texture = load("res://Assets/Icons/login.png")
			text = ""
		"CLS":
			text = ""
			$Icon.texture = load("res://Assets/Icons/unchecked.png")
		_:
			$Icon.queue_free()
