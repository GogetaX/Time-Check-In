tool
extends Control

const SelectedColor = Color("#fbffb326")
const UnSelectedColor = Color("#bce0fd")

var font = preload("res://Prefabs/Styles/Fonts/Size30.tres")

export (String) var VarList = "" setget SetVarList
export (bool) var SelectedAll = true setget SetSelectedAll
export (String) var DefaultSelection = "" setget SetDefaultSelection

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
				x.set("custom_colors/font_color",SelectedColor)
			else:
				x.set("custom_colors/font_color",UnSelectedColor)
			
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
		lbl.set("custom_fonts/font",font)
		$HBoxContainer.add_child(lbl)
		if DefaultSelection != "":
			if x == DefaultSelection:
				lbl.set("custom_colors/font_color",SelectedColor)
			else:
				lbl.set("custom_colors/font_color",UnSelectedColor)
		last_comma = Label.new()
		last_comma.text = ", "
		last_comma.set("custom_fonts/font",font)
		$HBoxContainer.add_child(last_comma)
	if last_comma != null:
		$HBoxContainer.remove_child(last_comma)
	SetSelectedAll(SelectedAll)
	
