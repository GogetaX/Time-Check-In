@tool
extends Control

const SelectedColor = Color("#ffb326fb")
const UnSelectedColor = Color("#bce0fd")

var font = preload("res://Prefabs/Styles/Fonts/Size30.tres")

@export var VarList: String = "": set = SetVarList
@export var SelectedAll: bool = true: set = SetSelectedAll
@export var DefaultSelection: String = "": set = SetDefaultSelection

func SetVarList(new):
	VarList = new
	SyncVars()
	
func SetDefaultSelection(new):
	DefaultSelection = new
	SyncVars()
	
func SetSelectedAll(new):
	SelectedAll = new
	if SelectedAll:
		for x in $HBoxContainer.get_children():
			if x.text != ", ":
				x.set("theme_override_colors/font_color",SelectedColor)
			else:
				x.set("theme_override_colors/font_color",UnSelectedColor)
			
func SyncVars():
	for x in $HBoxContainer.get_children():
		x.queue_free()
	if VarList == "":
		return
	var v = VarList.split(",")
	var last_comma = null
	for x in v:
		var lbl = Label.new()
		lbl.text = x
		lbl.set("theme_override_fonts/font",font)
		$HBoxContainer.add_child(lbl)
		if DefaultSelection != "":
			if x == DefaultSelection:
				lbl.set("theme_override_colors/font_color",SelectedColor)
			else:
				lbl.set("theme_override_colors/font_color",UnSelectedColor)
		last_comma = Label.new()
		last_comma.text = ", "
		last_comma.set("theme_override_fonts/font",font)
		$HBoxContainer.add_child(last_comma)
	if last_comma != null:
		$HBoxContainer.remove_child(last_comma)
	SetSelectedAll(SelectedAll)
	
