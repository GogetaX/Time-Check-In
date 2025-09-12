extends Control


const SelectedColor = Color("#ffb326fb")
const UnSelectedColor = Color("#bce0fd")

var CurSelected = null


func _ready():
	FastSelect("csv")

func FastSelect(lbl_name):
	CurSelected = null
	for x in $HBoxContainer.get_children():
		if x.name ==lbl_name:
			x.set("theme_override_colors/font_color",SelectedColor)
			CurSelected = x
		else:
			x.set("theme_override_colors/font_color",UnSelectedColor) 
