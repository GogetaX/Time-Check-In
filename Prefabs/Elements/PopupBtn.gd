@tool
extends Button

@export var iconType = "EMPTY": set = SetIconType

func SetIconType(new):
	iconType = new
	var FontColor = get_color("font_color")
	var ShaderDup = $Icon.material.duplicate()
	$Icon.material = ShaderDup
	$Icon.material.set("shader_param/u_replacement_color",FontColor)
	match iconType:
		"EMPTY":
			$Icon.texture = null
		"NO":
			$Icon.texture = load("res://Assets/Icons/unchecked.png")
		"YES":
			$Icon.texture = load("res://Assets/Icons/check-mark.png")
		"NEXT":
			$Icon.texture = load("res://Assets/Icons/next.png")
		"STOP":
			$Icon.texture = load("res://Assets/Icons/stop.png")
		"EDIT":
			$Icon.texture = load("res://Assets/Icons/editing.png")
		"EXPORT":
			$Icon.texture = load("res://Assets/Icons/export.png")
		"EMAIL":
			$Icon.texture = load("res://Assets/Icons/email.png")
