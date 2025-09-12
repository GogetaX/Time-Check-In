extends Panel

var ToolBtnInstance = preload("res://Prefabs/Elements/ToolBtn.tscn")

@export var has_goto: bool = true

func _ready():
	ClearTools()

func ClearTools():
	for x in $ScrollContainer/HBoxContainer.get_children():
		if x is Button:
			x.queue_free()
	$ScrollContainer/HBoxContainer/Label.text = ""

func ShowTools(ToolArray, emit_node, emit_func):
	ClearTools()
	for x in ToolArray:
		if x.size() > 0:
			var Btn = ToolBtnInstance.instantiate()
			Btn.text = "        " + TranslationServer.translate(x[0])
			Btn.connect("ButtonPressed", Callable(emit_node, emit_func).bind(x[0]))
			Btn.focus_mode = Control.FOCUS_NONE
			$ScrollContainer/HBoxContainer.add_child(Btn)
			if x.size() >= 2:
				Btn.SetBtnTexture(x[1])
			if x.size() >= 3:
				Btn.modulate = x[2]
	if $ScrollContainer/HBoxContainer.get_child_count() > 1 && has_goto:
		$ScrollContainer/HBoxContainer/Label.text = "Go to"

func _on_ScrollContainer_mouse_entered():
	GlobalTime.SwipeEnabled = false

func _on_ScrollContainer_mouse_exited():
	GlobalTime.SwipeEnabled = true
