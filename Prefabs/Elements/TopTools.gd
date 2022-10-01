extends Panel

var ToolBtnInstance = preload("res://Prefabs/Elements/ToolBtn.tscn")

func _ready():
	ClearTools()

func ClearTools():
	for x in $HBoxContainer.get_children():
		if x is Button:
			x.queue_free()
	$HBoxContainer/Label.text = ""
	
func ShowTools(ToolArray,emit_node,emit_func):
	ClearTools()
	for x in ToolArray:
		if x.size() > 0:
			var Btn = ToolBtnInstance.instance()
			Btn.text = "        "+TranslationServer.translate(x[0])
			Btn.connect("button_up",emit_node,emit_func,[x[0]])
			Btn.focus_mode = Control.FOCUS_NONE
			$HBoxContainer.add_child(Btn)
			if x.size()==2:
				Btn.SetBtnTexture(x[1])
	
	if $HBoxContainer.get_child_count()>1:
		$HBoxContainer/Label.text = "Go to"
